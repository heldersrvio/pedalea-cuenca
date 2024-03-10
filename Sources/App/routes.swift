import Fluent
import Vapor

func routes(_ app: Application) throws {
	let routingService = RoutingService(db: app.db)

	try app.register(collection: RoutingController(routingService: routingService))
	try app.register(collection: UsersController())
}
