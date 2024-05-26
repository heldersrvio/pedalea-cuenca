// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "ciclo-cuenca",
    platforms: [
       .macOS(.v13)
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "4.89.0"),
        // 🗄 An ORM for SQL and NoSQL databases.
        .package(url: "https://github.com/vapor/fluent.git", from: "4.8.0"),
        // 🐘 Fluent driver for Postgres.
        .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.7.2"),
		.package(url: "https://github.com/vapor/fluent-kit.git", from: "1.47.1"),
		.package(url: "https://github.com/vapor/jwt.git", from: "4.2.2"),
		.package(url: "https://github.com/heldersrvio/google-cloud-kit.git", branch: "main"),
		.package(url: "https://github.com/apple/app-store-server-library-swift.git", .upToNextMinor(from: "2.1.0")),
    ],
    targets: [
        .executableTarget(
            name: "App",
            dependencies: [
                .product(name: "Fluent", package: "fluent"),
                .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver"),
                .product(name: "Vapor", package: "vapor"),
				.product(name: "JWT", package: "jwt"),
				.product(name: "GoogleCloudKit", package: "google-cloud-kit"),
				.product(name: "AppStoreServerLibrary", package: "app-store-server-library-swift"),
            ]
        ),
        .testTarget(name: "AppTests", dependencies: [
            .target(name: "App"),
            .product(name: "XCTVapor", package: "vapor"),
			.product(name: "XCTFluent", package: "fluent-kit"),

            // Workaround for https://github.com/apple/swift-package-manager/issues/6940
            .product(name: "Vapor", package: "vapor"),
            .product(name: "Fluent", package: "Fluent"),
            .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver"),
        ])
    ]
)
