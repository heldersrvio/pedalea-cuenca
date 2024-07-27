import Fluent

struct HasDiscountMigration: AsyncMigration {
	func prepare(on database: Database) async throws {
		try await database.schema("users")
			.field("has_discount", .bool)
			.update()
	}

	func revert(on database: Database) async throws {
		try await database.schema("users")
			.deleteField("has_discount")
			.update()
	}
}

