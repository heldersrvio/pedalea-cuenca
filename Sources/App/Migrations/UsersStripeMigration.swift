import Fluent

struct UsersStripeMigration: AsyncMigration {
	func prepare(on database: Database) async throws {
		try await database.schema("users")
			.field("stripe_id", .string)
			.field("subscription_active", .bool)
			.update()
	}

	func revert(on database: Database) async throws {
		try await database.schema("users")
			.deleteField("subscription_active")
			.deleteField("stripe_id")
			.update()
	}
}
