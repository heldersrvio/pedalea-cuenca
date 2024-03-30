import Vapor

struct GooglePaymentService {

	func decodePayload(_ payload: String) throws -> GoogleRTDN {
		let decoder = JSONDecoder()
		guard let decodedData = Data(base64Encoded: payload) else {
			throw Abort(.notFound)
		}
		return try decoder.decode(GoogleRTDN.self, from: decodedData)
	}
}

