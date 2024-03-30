import Vapor
import JWTKit

final class AppleNotificationData: Content {
	var appAppleId: String?
	var bundleId: String
	var bundleVersion: String
	var environment: String
	var signedRenewalInfo: String
	var signedTransactionInfo: String
	var status: Int
}

final class AppleNotificationPayload: JWTPayload {
	enum CodingKeys: String, CodingKey {
		case subject = "sub"
		case expires = "exp"
		case issuer = "iss"
		case issuedAt = "iat"
		case notificationType = "notificationType"
		case subType = "subType"
		case version = "version"
		case signedDate = "signedDate"
		case notificationUUID = "notificationUUID"
		case data = "data"
	}

	public var issuer: IssuerClaim
	public var expires: ExpirationClaim
	public var issuedAt: IssuedAtClaim
	public var subject: SubjectClaim
	public var notificationType: String?
	public var subType: String?
	public var version: String
	public var signedDate: Double
	public var notificationUUID: String
	public var data: AppleNotificationData?

	public func verify(using signer: JWTSigner) throws {
		guard self.issuer.value == "https://appleid.apple.com" else {
            throw JWTError.claimVerificationFailure(name: "Issuer", reason: "Payload not provided by Apple")
        }
		try self.expires.verifyNotExpired()
	}
}

