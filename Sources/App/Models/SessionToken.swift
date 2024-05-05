import Vapor
import JWT

struct SessionToken: Content, Authenticatable, JWTPayload {

	let expirationTime: TimeInterval = 60 * 60 * 3

	var expiration: ExpirationClaim

	var userId: UUID

	var isSubscriptionActive: Bool

	init(userId: UUID, isSubscriptionActive: Bool) {
		self.userId = userId
		self.expiration = ExpirationClaim(value: Date().addingTimeInterval(expirationTime))
		self.isSubscriptionActive = isSubscriptionActive
	}

	init(user: User) throws {
		self.userId = try user.requireID()
		self.expiration = ExpirationClaim(value: Date().addingTimeInterval(expirationTime))
		self.isSubscriptionActive = user.isSubscriptionActive ?? false
	}

	func verify(using signer: JWTSigner) throws {
		try expiration.verifyNotExpired()
	}
}

