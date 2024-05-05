import Fluent
import Vapor

struct RoutingController: RouteCollection {
	let routingService: RoutingService

	func boot(routes: RoutesBuilder) throws {
		let routing = routes.grouped(SessionToken.authenticator(), SessionToken.guardMiddleware(), SubscribedUserMiddleware()).grouped("routing")
		routing.post(use: calculateRoute)
	}

	func calculateRoute(req: Request) async throws -> [Route] {
		let query = try req.query.decode(CalculateRouteQuery.self)
		guard let startingLat = query.startingLat, let startingLon = query.startingLon, let destinationLat = query.destinationLat, let destinationLon = query.destinationLon else {
			throw Abort(.badRequest)
		}
		guard let startingCoordinates = try await self.routingService.getClosestCoordinates(to: (startingLat, startingLon)) else {
			throw Abort(.notFound)
		}
		guard let destinationCoordinates = try await self.routingService.getClosestCoordinates(to: (destinationLat, destinationLon)) else {
			throw Abort(.notFound)
		}
		guard let startingPointId = startingCoordinates.id, let destinationPointId = destinationCoordinates.id else {
			throw Abort(.notFound)
		}
		guard let routes = try await routingService.calculateRoute(from: startingPointId, to: destinationPointId) else {
			throw Abort(.notFound)
		}
		return routes
	}

	init(routingService: RoutingService) {
		self.routingService = routingService
	}
}
