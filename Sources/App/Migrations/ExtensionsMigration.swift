import FluentSQL

struct ExtensionsMigration: AsyncMigration {
	func prepare(on database: Database) async throws {
		try await (database as! SQLDatabase)
			.raw("CREATE EXTENSION IF NOT EXISTS PostGIS")
			.run()
		try await (database as! SQLDatabase)
			.raw("CREATE EXTENSION IF NOT EXISTS pgRouting")
			.run()
	}

	func revert(on database: Database) async throws {
		try await (database as! SQLDatabase)
			.raw("DROP EXTENSION IF EXISTS pgRouting")
			.run()
		try await (database as! SQLDatabase)
			.raw("DROP EXTENSION IF EXISTS PostGIS")
			.run()
	}
}

