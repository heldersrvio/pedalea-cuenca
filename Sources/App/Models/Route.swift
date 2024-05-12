import Vapor
import Fluent

final class Route: Model, Content {
	
	static let schema = "ways"

	@ID(custom: "seq")
	var id: Int?

	@Field(key: "path_seq")
	var pathSeq: Int

	@Field(key: "node")
	var node: Int

	@Field(key: "edge")
	var edge: Int

	@Field(key: "cost")
	var cost: Double

	@Field(key: "agg_cost")
	var aggCost: Double
	
	@Field(key: "lat1")
	var lat1: Double?

	@Field(key: "lon1")
	var lon1: Double?

	@Field(key: "lat2")
	var lat2: Double?

	@Field(key: "lon2")
	var lon2: Double?

	@Field(key: "is_cycle_lane")
	var isCycleLane: Bool

	init() {}

}

