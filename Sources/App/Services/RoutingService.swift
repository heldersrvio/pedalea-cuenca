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
			SELECT dijkstra.seq AS seq, dijkstra.path_seq AS path_seq, dijkstra.node AS node, dijkstra.edge AS edge, dijkstra.cost AS cost, dijkstra.agg_cost AS agg_cost, ways.x1 AS lon1, ways.y1 AS lat1, ways.x2 AS lon2, ways.y2 AS lat2,
			CASE
				WHEN LEFT(tag_id::TEXT, 1) IN ('1', '2', '3', '4') THEN TRUE
				WHEN tag_id = 501 THEN TRUE
				ELSE FALSE
			END AS is_cycle_lane
			FROM pgr_Dijkstra('select gid as id, source, target, cost, reverse_cost from ways', \(bind: startingPoint), \(bind: destinationPoint), true) AS dijkstra
			LEFT JOIN ways ON (edge = gid)
			""").all(decoding: Route.self)
		} else {
			return try await self.db.query(Route.self).all()
		}
	}

	init(db: Database) {
		self.db = db	
	}
}

