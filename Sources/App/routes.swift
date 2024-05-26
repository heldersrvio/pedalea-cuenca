import Fluent
import Vapor

func routes(_ app: Application) throws {
	let routingService = RoutingService(db: app.db)
	let applePaymentService = ApplePaymentService()

	try app.register(collection: RoutingController(routingService: routingService))
	try app.register(collection: UsersController())
	try app.register(collection: PaymentsController(applePaymentService: applePaymentService))
}
