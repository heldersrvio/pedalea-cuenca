import Vapor
import JWT

struct GooglePaymentService {

	let jwt: Request.JWT

	func verify(_ token: String) async throws -> Void {
		let signers = try await self.jwt._request.application.jwt.google.signers(
			on: self.jwt._request
		)
		try signers.verify(token, as: GoogleAuthenticationToken.self)
	}
		

	func decodePayload(_ payload: String) throws -> GoogleRTDN {
		let decoder = JSONDecoder()
		guard let decodedData = Data(base64Encoded: payload) else {
			throw Abort(.notFound)
		}
		return try decoder.decode(GoogleRTDN.self, from: decodedData)
	}

	init(jwt: Request.JWT) {
		self.jwt = jwt
	}
}

