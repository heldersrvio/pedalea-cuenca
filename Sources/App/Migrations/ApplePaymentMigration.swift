import Fluent

struct ApplePaymentMigration: AsyncMigration {
	func prepare(on database: Database) async throws {
		try await database.schema("users")
			.field("apple_app_account_token", .string)
			.field("subscription_active", .bool)
			.update()
	}

	func revert(on database: Database) async throws {
		try await database.schema("users")
			.deleteField("subscription_active")
			.deleteField("apple_app_account_token")
			.update()
	}
}

