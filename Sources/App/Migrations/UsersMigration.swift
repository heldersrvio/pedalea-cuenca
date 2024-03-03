import Fluent

struct UsersMigration: AsyncMigration {
	func prepare(on database: Database) async throws {
		try await database.schema("users")
			.id()
			.field("name", .string, .required)
			.field("email", .string, .required)
			.unique(on: "email")
			.create()
	}

	func revert(on database: Database) async throws {
		try await database.schema("users").delete()
	}
}

