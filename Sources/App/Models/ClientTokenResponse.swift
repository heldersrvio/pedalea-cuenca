import Vapor

final class ClientTokenResponse: Content {
	var userId: String
	var userName: String?
	var token: String

	init(userId: String, userName: String? = nil, token: String) {
		self.userId = userId
		self.userName = userName
		self.token = token
	}
}

