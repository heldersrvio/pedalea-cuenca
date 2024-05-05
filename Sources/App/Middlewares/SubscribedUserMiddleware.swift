import Vapor

struct SubscribedUserMiddleware: AsyncMiddleware {
	func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
		guard let token = request.auth.get(SessionToken.self), token.isSubscriptionActive == true else {
			throw Abort(.unauthorized)
		}
		return try await next.respond(to: request)
	}
}

