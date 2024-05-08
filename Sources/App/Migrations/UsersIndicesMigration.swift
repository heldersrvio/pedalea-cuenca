import Fluent
import SQLKit

struct UserIndicesMigration: AsyncMigration {
	func prepare(on database: Database) async throws {
		try await (database as! SQLDatabase)
			.create(index: "email_index")
			.on("users")
			.column("email")
			.run()
		try await (database as! SQLDatabase)
			.create(index: "google_purchase_token_index")
			.on("users")
			.column("google_purchase_token")
			.run()
		try await (database as! SQLDatabase)
			.create(index: "apple_app_account_token_index")
			.on("users")
			.column("apple_app_account_token")
			.run()
	}

	func revert(on database: Database) async throws {
		try await (database as! SQLDatabase)
			.drop(index: "apple_app_account_token_index")
			.run()
		try await (database as! SQLDatabase)
			.drop(index: "google_purchase_token_index")
			.run()
		try await (database as! SQLDatabase)
			.drop(index: "email_index")
			.run()
	}
}

