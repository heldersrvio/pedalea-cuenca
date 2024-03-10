import Vapor
import JWT

struct GoogleAuthService {
	
	let jwt: Request.JWT 
	let appIdentifier: String = Environment.get("GOOGLE_APP_IDENTIFIER")! 

	func verifyIdToken(_ idToken: String) async throws -> GoogleIdentityToken {
		return try await self.jwt.google.verify(idToken, applicationIdentifier: appIdentifier)
	}

	init(jwt: Request.JWT) {
		self.jwt = jwt
	}
}

