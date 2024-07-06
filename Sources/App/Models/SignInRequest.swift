import Vapor

enum AuthenticationProvider: String, Codable {
	case google, apple
}

final class SignInRequest: Content {
	var idToken: String
	var nonce: String?
	var authenticationProvider: AuthenticationProvider?
}

