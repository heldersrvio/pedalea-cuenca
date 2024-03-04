import Vapor
import JWT

struct SessionToken: Content, Authenticatable, JWTPayload {

	let expirationTime: TimeInterval = 60 * 60 * 3

	var expiration: ExpirationClaim

	var userId: UUID

	init(userId: UUID) {
		self.userId = userId
		self.expiration = ExpirationClaim(value: Date().addingTimeInterval(expirationTime))
	}

	init(user: User) throws {
		self.userId = try user.requireID()
		self.expiration = ExpirationClaim(value: Date().addingTimeInterval(expirationTime))
	}

	func verify(using signer: JWTSigner) throws {
		try expiration.verifyNotExpired()
	}
}

