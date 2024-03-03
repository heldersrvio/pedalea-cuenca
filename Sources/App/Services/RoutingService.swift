import FluentSQL
import Vapor

typealias Coordinates = (Double, Double)

struct RoutingService {
	let db: Database

	func getClosestCoordinates(to referenceCoordinates: Coordinates) async throws -> CoordinateResult? {
		let pointStr = "POINT(\(referenceCoordinates.1) \(referenceCoordinates.0))"
		if let sql = self.db as? SQLDatabase {
			return try await sql.raw("""
			SELECT id, lat, lon FROM ways_vertices_pgr
			ORDER BY the_geom <-> ST_GeometryFromText(\(bind: pointStr),4326)
			LIMIT 1
			""").first(decoding: CoordinateResult.self)
		} else {
			return try await self.db.query(CoordinateResult.self).first()
		}
	}

	func calculateRoute(from startingPoint: Int, to destinationPoint: Int) async throws -> [Route]? {
		if let sql = self.db as? SQLDatabase {
			return try await sql.raw("""
			SELECT * FROM pgr_Dijkstra('select gid as id, source, target, cost, reverse_cost from ways', \(bind: startingPoint), \(bind: destinationPoint), false)
			""").all(decoding: Route.self)
		} else {
			return try await self.db.query(Route.self).all()
		}
	}

	init(db: Database) {
		self.db = db	
	}
}

