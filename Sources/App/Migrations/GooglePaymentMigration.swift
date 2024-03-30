import Fluent

struct GooglePaymentMigration: AsyncMigration {
	func prepare(on database: Database) async throws {
		try await database.schema("users")
			.field("google_purchase_token", .string)
			.update()
	}
	
	func revert(on database: Database) async throws {
		try await database.schema("users")
			.deleteField("google_purchase_token")
			.update()
	}
}

