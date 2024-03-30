import Vapor
import JWT

struct ApplePaymentService {

	let jwt: Request.JWT

	func decodePayload(_ payload: String) async throws -> AppleNotificationPayload {
		let signers = try await self.jwt._request.application.jwt.apple.signers(
			on: self.jwt._request
        )
		return try signers.verify(payload, as: AppleNotificationPayload.self)
	}

	func decodeTransactionInfo(_ transactionInfo: String) async throws -> AppleTransactionInfo {
		let signers = try await self.jwt._request.application.jwt.apple.signers(
			on: self.jwt._request
        )
		return try signers.verify(transactionInfo, as: AppleTransactionInfo.self)
	}

	init(jwt: Request.JWT) {
		self.jwt = jwt
	}
}

