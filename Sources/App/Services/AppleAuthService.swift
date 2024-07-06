import Vapor
import JWT

struct AppleAuthService {
	
	let jwt: Request.JWT
	let appIdentifier: String = Environment.get("APPLICATION_PACKAGE_NAME")!

	func verifyIdToken(_ idToken: String) async throws -> AppleIdentityToken {
		return try await self.jwt.apple.verify(idToken, applicationIdentifier: appIdentifier)
	}

	init(jwt: Request.JWT) {
		self.jwt = jwt
	}
}

