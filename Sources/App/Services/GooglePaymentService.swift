import Vapor
import JWT
import AndroidPublisher
import Core

class GooglePaymentService {

	let jwt: Request.JWT
	let androidPublisherClient: GoogleCloudAndroidPublisherClient
	let httpClient: HTTPClient

	func verify(_ token: String) async throws -> Void {
		let signers = try await self.jwt._request.application.jwt.google.signers(
			on: self.jwt._request
		)
		try signers.verify(token, as: GoogleAuthenticationToken.self)
	}
		

	func decodePayload(_ payload: String) throws -> GoogleRTDN {
		let decoder = JSONDecoder()
		guard let decodedData = Data(base64Encoded: payload) else {
			throw Abort(.notFound)
		}
		return try decoder.decode(GoogleRTDN.self, from: decodedData)
	}

	func getSubscriptionStatus(token: String) async throws -> GoogleCloudSubscriptionState {
		let packageName = Environment.get("APPLICATION_PACKAGE_NAME")!
		let response = try await self.androidPublisherClient.purchases.get(packageName: packageName, token: token).get()
		return response.subscriptionState ?? .unspecified
	}

	init(jwt: Request.JWT, app: Application, eventLoop: EventLoop) throws {
		self.jwt = jwt
		let credentials = try GoogleCloudCredentialsConfiguration()
		let androidPublisherConfiguration = GoogleCloudAndroidPublisherConfiguration(scope: [.androidPublisher], serviceAccount: Environment.get("GOOGLE_PUB_SUB_SERVICE_ACCOUNT")!, project: Environment.get("GOOGLE_PROJECT_ID")!)
		self.httpClient = HTTPClient(eventLoopGroupProvider: .singleton,
                            configuration: HTTPClient.Configuration())	
		self.androidPublisherClient = try GoogleCloudAndroidPublisherClient(credentials: credentials, config: androidPublisherConfiguration, httpClient: httpClient, eventLoop: eventLoop)
	}

	deinit {
		self.httpClient.shutdown()
	}
}

