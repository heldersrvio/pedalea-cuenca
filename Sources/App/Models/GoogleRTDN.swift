import Vapor

struct SubscriptionNotification: Content {
	var version: String
	var notificationType: Int
	var purchaseToken: String
	var subscriptionId: String
}

struct TestNotification: Content {
	var version: String
}

struct GoogleRTDN: Content {
	var version: String
	var packageName: String
	var eventTimeMillis: String
	var subscriptionNotification: SubscriptionNotification?
	var testNotification: TestNotification?
}

