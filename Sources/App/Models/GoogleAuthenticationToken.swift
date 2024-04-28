import Vapor
import JWTKit

final class GoogleAuthenticationToken: JWTPayload {
	enum CodingKeys: String, CodingKey {
		case audience = "aud"
		case email = "email"
		case clientId = "azp"
		case subject = "sub"
		case emailVerified = "email_verified"
		case expires = "exp"
		case issuer = "iss"
		case issuedAt = "iat"
	}

	public var audience: AudienceClaim?
	public var email: String
	public var emailVerified: Bool
	public var clientId: String
	public var issuer: IssuerClaim
	public var expires: ExpirationClaim
	public var issuedAt: IssuedAtClaim
	public var subject: SubjectClaim

	public func verify(using signer: JWTSigner) throws {
		guard self.issuer.value == "https://accounts.google.com" else {
            throw JWTError.claimVerificationFailure(name: "Issuer", reason: "Payload not provided by Google")
        }
		guard self.email == Environment.get("GOOGLE_PUB_SUB_SERVICE_ACCOUNT") else {
			throw JWTError.claimVerificationFailure(name: "Email", reason: "Email not the same as service account")
		}
		guard self.emailVerified else {
			throw JWTError.claimVerificationFailure(name: "Email verified", reason: "Email not verified")
		}
		try self.expires.verifyNotExpired()
	}
}

