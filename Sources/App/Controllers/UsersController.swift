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
			user.delete(use: delete)
		}
	}

	func signIn(req: Request) async throws -> ClientTokenResponse {
		let signInRequest = try req.content.decode(SignInRequest.self)
		if (signInRequest.authenticationProvider == .apple) {
			return try await signInWithApple(req: req)
		} else {
			return try await signInWithGoogle(req: req)
		}
	}

	private func signInWithGoogle(req: Request) async throws -> ClientTokenResponse {
		let signInRequest = try req.content.decode(SignInRequest.self)
		let authService = GoogleAuthService(jwt: req.jwt)
		let token = try await authService.verifyIdToken(signInRequest.idToken)
		guard let email = token.email else {
			throw Abort(.unauthorized, reason: "Email not present in token")
		}
		if let user = try await User.query(on: req.db).filter(\.$email == email).first(), let userId = user.id, let userName = user.name, let isSubscriptionActive = user.isSubscriptionActive {
			let jwtPayload = SessionToken(userId: userId, isSubscriptionActive: isSubscriptionActive, googlePurchaseToken: user.googlePurchaseToken, appleAppAccountToken: user.appleAppAccountToken)
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
		let jwtPayload = SessionToken(userId: newUserId, isSubscriptionActive: newUserSubscriptionStatus, googlePurchaseToken: newUser.googlePurchaseToken, appleAppAccountToken: newUser.appleAppAccountToken)
		return ClientTokenResponse(userId: newUserId.uuidString, userName: name, token: try req.jwt.sign(jwtPayload))
	}
	
	private func signInWithApple(req: Request) async throws -> ClientTokenResponse {
		let signInRequest = try req.content.decode(SignInRequest.self)
		let authService = AppleAuthService(jwt: req.jwt)
		let token = try await authService.verifyIdToken(signInRequest.idToken)
		guard let email = token.email else {
			throw Abort(.unauthorized, reason: "Email not present in token")
		}
		if let user = try await User.query(on: req.db).filter(\.$email == email).first(), let userId = user.id, let isSubscriptionActive = user.isSubscriptionActive {
			let jwtPayload = SessionToken(userId: userId, isSubscriptionActive: isSubscriptionActive, googlePurchaseToken: user.googlePurchaseToken, appleAppAccountToken: user.appleAppAccountToken)
			return ClientTokenResponse(userId: userId.uuidString, token: try req.jwt.sign(jwtPayload))
		}
		let newUser = User(email: email)
		try await newUser.save(on: req.db)
		guard let newUserId = newUser.id, let newUserSubscriptionStatus = newUser.isSubscriptionActive else {
			throw Abort(.unauthorized, reason: "Could not save user")
		}
		let jwtPayload = SessionToken(userId: newUserId, isSubscriptionActive: newUserSubscriptionStatus, googlePurchaseToken: newUser.googlePurchaseToken, appleAppAccountToken: newUser.appleAppAccountToken)
		return ClientTokenResponse(userId: newUserId.uuidString, token: try req.jwt.sign(jwtPayload))
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
		if let updatedUserAppleAppAccountToken = updatedUser.appleAppAccountToken {
			user.appleAppAccountToken = updatedUserAppleAppAccountToken
		}
		try await user.save(on: req.db)
		return user
	}

	func delete(req: Request) async throws -> HTTPStatus {
		let sessionToken = try req.auth.require(SessionToken.self)
        guard sessionToken.userId == req.parameters.get("id") else {
            throw Abort(.unauthorized)
        }
        guard let user = try await User.find(req.parameters.get("id"), on: req.db) else {
            throw Abort(.notFound)
        }
		try await user.delete(on: req.db)
		return .ok
	}
}
