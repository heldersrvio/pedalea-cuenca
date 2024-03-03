import Vapor

struct CalculateRouteQuery: Content {
	var startingLat: Double?
	var startingLon: Double?
	var destinationLat: Double?
	var destinationLon: Double?
}

