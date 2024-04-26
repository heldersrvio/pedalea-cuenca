import Vapor
import Fluent

struct PaymentsController: RouteCollection {
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
		let applePaymentService = ApplePaymentService(jwt: req.jwt)
		let responseBodyV2 = try req.content.decode(AppleResponseBodyV2.self)
		let payload = try await applePaymentService.decodePayload(responseBodyV2.signedPayload)
		guard let signedTransactionInfo = payload.data?.signedTransactionInfo else {
			return .ok
		}
		let transactionInfo = try await applePaymentService.decodeTransactionInfo(signedTransactionInfo)
		guard let appAccountToken = transactionInfo.appAccountToken else {
			throw Abort(.notFound)
		}
		guard let user = try await User.query(on: req.db)
			.filter(\.$appleAppAccountToken == appAccountToken)
			.first(), let userId = user.id else {
				throw Abort(.notFound)
		}
		guard let notificationType = payload.notificationType else {
			throw Abort(.notFound)
		}
		print("Received \(notificationType) for user \(userId)")
		switch notificationType {
		case "DID_RENEW", "SUBSCRIBED":
			user.isSubscriptionActive = true
			try await user.save(on: req.db)
		case "REVOKE", "GRACE_PERIOD_EXPIRED", "EXPIRED":
			user.isSubscriptionActive = false
			try await user.save(on: req.db)
		default:
			print("Notification type not handled")
		}
		return .ok
	}

	func handleGoogleNotification(req: Request) async throws -> HTTPStatus {
		let googlePaymentService = GooglePaymentService()
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
		guard let user = try await User.query(on: req.db)
			.filter(\.$googlePurchaseToken == subscriptionNotification.purchaseToken)
			.first(), let userId = user.id else {
				print("User not found")
				throw Abort(.notFound)
		}
		print("Received Google's notification \(subscriptionNotification.notificationType) for user \(userId)")
		switch subscriptionNotification.notificationType {
		case 4, 7, 2:
			user.isSubscriptionActive = true
			try await user.save(on: req.db)
		case 3, 12, 13:
			user.isSubscriptionActive = false
			try await user.save(on: req.db)
		default:
			print("Notification type not handled")
		}
		return .ok
	}

}
