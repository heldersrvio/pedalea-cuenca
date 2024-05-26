import Vapor
import AppStoreServerLibrary

let BUNDLE_ID = "org.serviosoftware.ciclocuenca"

struct ApplePaymentService {

	let environment: AppStoreServerLibrary.Environment
	let verifier: SignedDataVerifier

	func decodePayload(_ payload: String) async throws -> ResponseBodyV2DecodedPayload {
		let notificationResult = await self.verifier.verifyAndDecodeNotification(signedPayload: payload)
		switch notificationResult {
			case .valid(let decodedNotification):
				return decodedNotification
			default:
				throw Abort(.unauthorized)
		}
	}

	func decodeTransactionInfo(_ transactionInfo: String) async throws -> JWSTransactionDecodedPayload {
		let transactionResult = await self.verifier.verifyAndDecodeTransaction(signedTransaction: transactionInfo)
		switch transactionResult {
			case .valid(let decodedTransaction):
				return decodedTransaction
			default:
				throw Abort(.unauthorized)
		}
	}

	init() {
		let appAppleId = Vapor.Environment.get("APP_APPLE_ID") == nil ? nil : Int64(Vapor.Environment.get("APP_APPLE_ID")!)
		if let appleEnvironment = Vapor.Environment.get("APPLE_ENVIRONMENT") {
			self.environment = AppStoreServerLibrary.Environment(rawValue: appleEnvironment) ?? .sandbox
		} else {
			self.environment = .sandbox
		}
		let certificates = Vapor.Environment.get("APPLE_CERTIFICATE_PATHS")!.components(separatedBy: ",").map { [] in
			return try! Data(contentsOf:
				URL(fileURLWithPath: $0)
			)
		}
		self.verifier = try! SignedDataVerifier(rootCertificates: certificates, bundleId: BUNDLE_ID, appAppleId: appAppleId, environment: self.environment, enableOnlineChecks: true)
	}
}

