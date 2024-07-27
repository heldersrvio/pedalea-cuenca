import JWT
import NIOSSL
import Fluent
import FluentPostgresDriver
import Vapor

// configures your application
public func configure(_ app: Application) async throws {
    app.databases.use(DatabaseConfigurationFactory.postgres(configuration: .init(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? SQLPostgresConfiguration.ianaPortNumber,
        username: Environment.get("DATABASE_USERNAME") ?? "postgres",
        password: Environment.get("DATABASE_PASSWORD") ?? "",
        database: Environment.get("DATABASE_NAME") ?? "ciclorrutas_cuenca",
        tls: .prefer(try .init(configuration: .clientDefault)))
    ), as: .psql)

	app.routes.defaultMaxBodySize = "1mb"

	let corsConfiguration = CORSMiddleware.Configuration(
		allowedOrigin: .any(["http://localhost", "http://localhost:5173", "https://www.pedaleacuenca.com", "https://pedaleacuenca.com"]),
		allowedMethods: [.GET, .POST, .PUT, .OPTIONS, .DELETE],
		allowedHeaders: [.accept, .authorization, .contentType, .origin, .xRequestedWith, .userAgent, .accessControlAllowOrigin]
	)
	let cors = CORSMiddleware(configuration: corsConfiguration)

	app.middleware.use(cors, at: .beginning)

    // register routes
    try routes(app)

	app.migrations.add(UsersMigration())
	app.migrations.add(ApplePaymentMigration())
	app.migrations.add(GooglePaymentMigration())
	app.migrations.add(UserIndicesMigration())
	app.migrations.add(ExtensionsMigration())
	app.migrations.add(HasDiscountMigration())

	app.jwt.signers.use(.hs256(key: Environment.get("JWT_KEY") ?? "secret"))
}
