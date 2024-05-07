import Vapor
import JWT

struct SessionToken: Content, Authenticatable, JWTPayload {

	let expirationTime: TimeInterval = 60 * 60 * 3

	var expiration: ExpirationClaim

	var userId: UUID

	var isSubscriptionActive: Bool

	var googlePurchaseToken: String?

	init(userId: UUID, isSubscriptionActive: Bool, googlePurchaseToken: String? = nil) {
		self.userId = userId
		self.expiration = ExpirationClaim(value: Date().addingTimeInterval(expirationTime))
		self.isSubscriptionActive = isSubscriptionActive
		self.googlePurchaseToken = googlePurchaseToken
	}

	init(user: User) throws {
		self.userId = try user.requireID()
		self.expiration = ExpirationClaim(value: Date().addingTimeInterval(expirationTime))
		self.isSubscriptionActive = user.isSubscriptionActive ?? false
		self.googlePurchaseToken = user.googlePurchaseToken
	}

	func verify(using signer: JWTSigner) throws {
		try expiration.verifyNotExpired()
	}
}

