import Vapor
import JWTKit

final class AppleTransactionInfo: JWTPayload {
	enum CodingKeys: String, CodingKey {
		case subject = "sub"
		case expires = "exp"
		case issuer = "iss"
		case issuedAt = "iat"
		case appAccountToken = "appAccountToken"
		case bundleId
		case currency
		case environment
		case expiresDate
		case isAppOwnershipType
		case isUpgraded
		case offerDiscountType
		case offerIdentifier
		case offerType
		case originalPurchaseDate
		case originalTransactionId
		case price
		case productId
		case purchaseDate
		case quantity
		case revocationDate
		case revocationReason
		case signedDate
		case storefront
		case storefrontId
		case subscriptionGroupIdentifier
		case transactionId
		case transactionReason
		case type
		case webOrderLineItemId
	}

	public var issuer: IssuerClaim
	public var expires: ExpirationClaim
	public var issuedAt: IssuedAtClaim
	public var subject: SubjectClaim
	public var appAccountToken: String?
	public var bundleId: String
	public var currency: String?
	public var environment: String
	public var expiresDate: Double?
	public var isAppOwnershipType: String?
	public var isUpgraded: Bool?
	public var offerDiscountType: String?
	public var offerIdentifier: String?
	public var offerType: String?
	public var originalPurchaseDate: Double
	public var originalTransactionId: String
	public var price: Int?
	public var productId: String
	public var purchaseDate: Double?
	public var quantity: Int?
	public var revocationDate: Double?
	public var revocationReason: Int?
	public var signedDate: Double?
	public var storefront: String?
	public var storefrontId: String?
	public var subscriptionGroupIdentifier: String?
	public var transactionId: String?
	public var transactionReason: String?
	public var type: String?
	public var webOrderLineItemId: String?
	
	public func verify(using signer: JWTSigner) throws {
		guard self.issuer.value == "https://appleid.apple.com" else {
            throw JWTError.claimVerificationFailure(name: "Issuer", reason: "Payload not provided by Apple")
        }
		try self.expires.verifyNotExpired()
	}
}

