import Vapor

struct GooglePubSubMessage: Content {
	var data: String?
	var attributes: [String:String]?
	var messageId: String
	var publishTime: Double
	var orderingKey: String?
}

