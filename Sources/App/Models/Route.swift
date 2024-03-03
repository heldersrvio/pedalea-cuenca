import Vapor
import Fluent

final class Route: Model, Content {
	
	static let schema = "ways"

	@ID(custom: "seq")
	var id: Int?

	@Field(key: "path_seq")
	var pathSeq: Int

	@Field(key: "start_vid")
	var startVid: Int

	@Field(key: "end_vid")
	var endVid: Int

	@Field(key: "node")
	var node: Int

	@Field(key: "edge")
	var edge: Int

	@Field(key: "cost")
	var cost: Double

	@Field(key: "agg_cost")
	var aggCost: Double

	init() {}

}

