import Vapor

struct GooglePubSubMessage: Content {
	var data: String?
	var attributes: [String:String]?
	var messageId: String
	var publishTime: String?
	var orderingKey: String?
}

struct GooglePubSubNotification: Content {
	var message: GooglePubSubMessage
	var subscription: String?
}

