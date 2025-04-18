import Vapor
import AppStoreServerLibrary
import Fluent

struct PaymentsController: RouteCollection {
	let applePaymentService: ApplePaymentService

	func boot(routes: RoutesBuilder) throws {
		let payments = routes.grouped("payments")
		payments.group("apple") { payment in
			payment.post(use: handleAppleNotification)
		}
		payments.group("google") { payment in
			payment.post(use: handleGoogleNotification)
		}
	}

	func handleAppleNotification(req: Request) async throws -> HTTPStatus {
		let responseBodyV2 = try req.content.decode(ResponseBodyV2.self)
		guard let signedPayload = responseBodyV2.signedPayload else {
			print("Could not find signed payload")
			return .ok
		}
		let payload = try await self.applePaymentService.decodePayload(signedPayload)
		print("Decoded payload")
		guard let signedTransactionInfo = payload.data?.signedTransactionInfo else {
			print("Signed transaction info not found")
			return .ok
		}
		let transactionInfo = try await self.applePaymentService.decodeTransactionInfo(signedTransactionInfo)
		print("Found transaction info")
		guard let appAccountToken = transactionInfo.appAccountToken?.uuidString.lowercased() else {
			print("App account token not found")
			throw Abort(.notFound)
		}
		guard let user = try await User.query(on: req.db)
			.filter(\.$appleAppAccountToken == appAccountToken)
			.first(), let userId = user.id else {
				print("User not found")
				throw Abort(.notFound)
		}
		guard let notificationType = payload.notificationType else {
			print("Notification type not found")
			throw Abort(.notFound)
		}
		print("Received \(notificationType) for user \(userId)")
		switch notificationType {
		case .didRenew, .subscribed:
			user.isSubscriptionActive = true
			try await user.save(on: req.db)
		case .revoke, .expired:
			user.appleAppAccountToken = nil
			fallthrough
		case .revoke, .gracePeriodExpired, .expired:
			user.isSubscriptionActive = false
			try await user.save(on: req.db)
		default:
			print("Notification type not handled")
		}
		return .ok
	}

	func handleGoogleNotification(req: Request) async throws -> HTTPStatus {
		if req.query["token"] != Environment.get("GOOGLE_PUB_SUB_TOKEN") {
			print("Missing or incorrect Google Pub Sub token")
			throw Abort(.unauthorized)
		}
		let googlePaymentService = try GooglePaymentService(jwt: req.jwt, app: req.application, eventLoop: req.eventLoop)
		guard let authenticationToken = req.headers.bearerAuthorization?.token else {
			print("Could not find Bearer authorization")
			throw Abort(.unauthorized)
		}
		do {
			try await googlePaymentService.verify(authenticationToken)
		} catch {
			print("Could not verify authentication token")
			throw Abort(.unauthorized)
		}

		let requestNotification = try req.content.decode(GooglePubSubNotification.self)
		let requestMessage = requestNotification.message
		guard let data = requestMessage.data else {
			print("No data found")
			return .ok
		}
		let payload = try googlePaymentService.decodePayload(data)
		guard let subscriptionNotification = payload.subscriptionNotification else {
			print("No subscription notification found")
			return .ok
		}
		print("Google purchase token: \(subscriptionNotification.purchaseToken)")

		let subscriptionStatus = try await googlePaymentService.getSubscriptionStatus(token: subscriptionNotification.purchaseToken)
		print("Subscription status: \(subscriptionStatus)")
		guard let user = try await User.query(on: req.db)
			.filter(\.$googlePurchaseToken == subscriptionNotification.purchaseToken)
			.first(), let userId = user.id else {
				print("Received Google's notification \(subscriptionNotification.notificationType)")
				print("User not found")

				switch subscriptionNotification.notificationType {
				case 3, 5, 10, 12, 13:
					return .ok
				default:
					throw Abort(.notFound)
				}
		}
		print("Received Google's notification \(subscriptionNotification.notificationType) for user \(userId)")
		switch subscriptionNotification.notificationType {
		case 1, 2, 4, 7:
			if subscriptionStatus == .active {
				user.isSubscriptionActive = true
				try await user.save(on: req.db)
			}
		case 12, 13:
			if subscriptionStatus == .canceled || subscriptionStatus == .expired {
				user.googlePurchaseToken = nil
				fallthrough
			}
		case 5, 10, 12, 13:
			if subscriptionStatus == .canceled || subscriptionStatus == .expired || subscriptionStatus == .onHold || subscriptionStatus == .paused {
				user.isSubscriptionActive = false
				try await user.save(on: req.db)
			}
		default:
			print("Notification type not handled")
		}
		return .ok
	}

	init(applePaymentService: ApplePaymentService) {
		self.applePaymentService = applePaymentService
	}
}
