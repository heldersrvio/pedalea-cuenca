import Vapor

struct UsersController: RouteCollection {
	func boot(routes: RoutesBuilder) throws {
		let secure = routes.grouped(SessionToken.authenticator(), SessionToken.guardMiddleware()).grouped("users")
		secure.group(":id") { user in
			user.get(use: show)
			user.put(use: update)
		}
	}

	func show(req: Request) async throws -> User {
		guard let user = try await User.find(req.parameters.get("id"), on: req.db) else {
			throw Abort(.notFound)
		}
		return user
	}

	func update(req: Request) async throws -> User {
		guard let user = try await User.find(req.parameters.get("id"), on: req.db) else {
			throw Abort(.notFound)
		}
		let updatedUser = try req.content.decode(User.self)
		user.name = updatedUser.name
		try await user.save(on: req.db)
		return user
	}
}

