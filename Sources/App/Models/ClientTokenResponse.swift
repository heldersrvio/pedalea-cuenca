import Vapor

final class ClientTokenResponse: Content {
	var userName: String
	var token: String

	init(userName: String, token: String) {
		self.userName = userName
		self.token = token
	}
}

