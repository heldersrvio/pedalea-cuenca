@testable import App
import FluentSQL
import XCTVapor
import XCTFluent

final class AppTests: XCTestCase {
	func testGetClosestCoordinates() async throws {
		let db = ArrayTestDatabase()
		db.append([
			TestOutput(["id": 2, "lat": -2.89726320, "lon": -79.00694560])
		])
		let routingService = RoutingService(db: db.db)
		let startingPoint = (-2.897406, -79.006874)
		guard let coordinates = try await routingService.getClosestCoordinates(to: startingPoint) else {
			XCTFail("Expected coordinates to be returned")
			return
		}
		XCTAssertEqual(coordinates.id, 2)
		XCTAssertEqual(coordinates.lat, startingPoint.0, accuracy: 0.001)
		XCTAssertEqual(coordinates.lon, startingPoint.1, accuracy: 0.001)	
	}

	func testCalculateRoute() async throws {
		let db = ArrayTestDatabase()
		db.append([
			TestOutput(["seq": 1, "path_seq": 1, "start_vid": 5030, "end_vid": 5100, "node": 5030, "edge": 7433, "cost": 0.52862497926604, "agg_cost": 0.0]),
			TestOutput(["seq": 2, "path_seq": 2, "start_vid": 5030, "end_vid": 5100, "node": 5033, "edge": 7434, "cost": 0.01388749234158229, "agg_cost": 0.52862497926604]),
			TestOutput(["seq": 3, "path_seq": 3, "start_vid": 5030, "end_vid": 5100, "node": 10283, "edge": 13933, "cost": 0.52862497926604, "agg_cost": 0.52862497926604]),
			TestOutput(["seq": 4, "path_seq": 4, "start_vid": 5030, "end_vid": 5100, "node": 5100, "edge": -1, "cost": 0.0, "agg_cost": 0.52862497926604]),
		])
		let routingService = RoutingService(db: db.db)
		let startingPointId = 5030
		let destinationPointId = 5100
		guard let routes = try await routingService.calculateRoute(from: startingPointId, to: destinationPointId) else {
			XCTFail("Expected route to be returned")
			return
		}
		XCTAssertEqual(routes.count, 4)
		XCTAssertEqual(routes[0].node, 5030)
		XCTAssertEqual(routes[3].node, 5100)
	}
}
