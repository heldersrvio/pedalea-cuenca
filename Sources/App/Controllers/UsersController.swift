import Vapor
import Fluent

struct UsersController: RouteCollection {
	func boot(routes: RoutesBuilder) throws {
		let login = routes.grouped("signin")
		login.post(use: signIn)
		let secure = routes.grouped(SessionToken.authenticator(), SessionToken.guardMiddleware()).grouped("users")
		secure.group(":id") { user in
			user.get(use: show)
			user.put(use: update)
		}
	}

	func signIn(req: Request) async throws -> ClientTokenResponse {
		let googleAuthService = GoogleAuthService(jwt: req.jwt)
		let signInRequest = try req.content.decode(SignInRequest.self)
		let token = try await googleAuthService.verifyIdToken(signInRequest.idToken)
		guard let email = token.email else {
			throw Abort(.unauthorized, reason: "Email not present in token")
		}
		if let user = try await User.query(on: req.db).filter(\.$email == email).first(), let userId = user.id, let userName = user.name, let isSubscriptionActive = user.isSubscriptionActive {
			let jwtPayload = SessionToken(userId: userId, isSubscriptionActive: isSubscriptionActive)
			return ClientTokenResponse(userId: userId.uuidString, userName: userName, token: try req.jwt.sign(jwtPayload))
		}
		guard let name = token.name else {
			throw Abort(.unauthorized, reason: "Name not present in token")
		}
		let newUser = User(name: name, email: email)
		try await newUser.save(on: req.db)
		guard let newUserId = newUser.id, let newUserSubscriptionStatus = newUser.isSubscriptionActive else {
			throw Abort(.unauthorized, reason: "Could not save user")
		}
		let jwtPayload = SessionToken(userId: newUserId, isSubscriptionActive: newUserSubscriptionStatus)
		return ClientTokenResponse(userId: newUserId.uuidString, userName: name, token: try req.jwt.sign(jwtPayload))
	}

	func show(req: Request) async throws -> User {
		let sessionToken = try req.auth.require(SessionToken.self)
		guard sessionToken.userId == req.parameters.get("id") else {
			throw Abort(.unauthorized)
		}
		guard let user = try await User.find(req.parameters.get("id"), on: req.db) else {
			throw Abort(.notFound)
		}
		return user
	}

	func update(req: Request) async throws -> User {
		let sessionToken = try req.auth.require(SessionToken.self)
		guard sessionToken.userId == req.parameters.get("id") else {
			throw Abort(.unauthorized)
		}
		guard let user = try await User.find(req.parameters.get("id"), on: req.db) else {
			throw Abort(.notFound)
		}
		let updatedUser = try req.content.decode(User.self)
		if let updatedUserName = updatedUser.name {
			user.name = updatedUserName
		}
		if let updatedUserGooglePurchaseToken = updatedUser.googlePurchaseToken {
			user.googlePurchaseToken = updatedUserGooglePurchaseToken
		}
		try await user.save(on: req.db)
		return user
	}
}
