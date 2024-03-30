import Fluent
import Vapor

final class User: Model, Content {

	static let schema = "users"

	@ID(key: .id)
	var id: UUID?

	@Field(key: "name")
	var name: String?

	@Field(key: "email")
	var email: String?

	@Field(key: "stripe_id")
	var stripeId: String?

	@Field(key: "apple_app_account_token")
	var appleAppAccountToken: String?

	@Field(key: "subscription_active")
	var isSubscriptionActive: Bool?

	init(id: UUID? = nil, name: String, email: String, stripeId: String? = nil, appleAppAccountToken: String? = nil, isSubscriptionActive: Bool? = false) {
		self.id = id
		self.name = name
		self.email = email
		self.isSubscriptionActive = isSubscriptionActive
	}

	init() { }
}

