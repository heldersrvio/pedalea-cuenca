import Fluent

final class CoordinateResult: Model {
	
	static let schema = "ways_vertices_pgr"

	@ID(custom: "id")
	var id: Int?

	@Field(key: "lat")
	var lat: Double

	@Field(key: "lon")
	var lon: Double

	init(id: Int? = nil, lat: Double, lon: Double) {
		self.id = id
		self.lat = lat
		self.lon = lon
	}

	init() { }
}

