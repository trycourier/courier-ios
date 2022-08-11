import XCTest
@testable import Courier

let rawApnsToken = Data([110, 157, 218, 189, 21, 13, 6, 181, 101, 205, 146, 170, 48, 254, 173, 48, 181, 30, 113, 220, 237, 83, 213, 213, 237, 248, 254, 211, 130, 206, 45, 20]) // This is fake
let fcmToken = "F15C9C75-D8D3-48A7-989F-889BEE3BE8D9" // This is fake
let userId = "example_user"
var authKey: String = "your_access_key"

final class CourierTests: XCTestCase {
    
    override class func setUp() {
        print("\n")
        print("🔑 Set your Courier Auth Key: ", terminator: "")
        authKey = readLine()!
        print("\n")
    }
    
    override func tearDown() async throws {
        print("\n")
    }
    
    func testA() async throws {
        
        print("\n🔬 Setting APNS Token before User")
        
        do {
            try await Courier.shared.setAPNSToken(rawApnsToken)
        } catch {
            XCTAssertEqual(Courier.shared.accessToken, nil)
            XCTAssertEqual(Courier.shared.userId, nil)
            XCTAssertEqual(Courier.shared.apnsToken, rawApnsToken.string)
        }

    }
    
    func testB() async throws {

        print("🔬 Setting FCM Token before User")
        
        do {
            try await Courier.shared.setFCMToken(fcmToken)
        } catch {
            XCTAssertEqual(Courier.shared.accessToken, nil)
            XCTAssertEqual(Courier.shared.userId, nil)
            XCTAssertEqual(Courier.shared.fcmToken, fcmToken)
        }

    }
    
    func testC() async throws {

        print("\n🔬 Starting Courier SDK with JWT")

        // Get the token from our custom endpoint
        // This should be your custom endpoint
        let accessToken = try await ExampleServer.generateJwt(userId: userId)

        // Set the access token and start the SDK
        try await Courier.shared.setCredentials(
            accessToken: accessToken,
            userId: userId
        )

        XCTAssertEqual(Courier.shared.accessToken, authKey)
        XCTAssertEqual(Courier.shared.userId, userId)
        XCTAssertEqual(Courier.shared.apnsToken, rawApnsToken.string)
        XCTAssertEqual(Courier.shared.fcmToken, fcmToken)

    }
    
    func testD() async throws {

        print("\n🔬 Starting Courier SDK with Auth Key")
        
        // TODO: Remove this. For test purposed only
        // Set the access token and start the SDK
        try await Courier.shared.setCredentials(
            accessToken: authKey,
            userId: userId
        )

        XCTAssertEqual(Courier.shared.accessToken, authKey)
        XCTAssertEqual(Courier.shared.userId, userId)
        XCTAssertEqual(Courier.shared.apnsToken, rawApnsToken.string)
        XCTAssertEqual(Courier.shared.fcmToken, fcmToken)

    }
    
    func testE() async throws {

        print("\n🔬 Testing APNS Token Update")
        
        try await Courier.shared.setAPNSToken(rawApnsToken)

        XCTAssertEqual(Courier.shared.accessToken != nil, true)
        XCTAssertEqual(Courier.shared.userId, userId)
        XCTAssertEqual(Courier.shared.fcmToken, fcmToken)

    }

    func testF() async throws {

        print("\n🔬 Testing FCM Token Update")
        
        try await Courier.shared.setFCMToken(fcmToken)

        XCTAssertEqual(Courier.shared.accessToken != nil, true)
        XCTAssertEqual(Courier.shared.userId, userId)
        XCTAssertEqual(Courier.shared.fcmToken, fcmToken)

    }
    
    func testG() async throws {

        print("\n🔬 Testing Sending Test Message")
        
        // TODO: Remove this. For test purposed only
        // Do not use auth key in production app
        let requestId = try await Courier.sendPush(
            authKey: authKey,
            userId: userId,
            title: "🐤 Chirp Chirp!",
            message: "Message sent from Xcode tests"
        )
        
        print("Request ID: \(requestId)")

        XCTAssertEqual(requestId.isEmpty, false)

    }
    
    func testH() async throws {

        print("\n🔬 Testing Tracking URL")
        
        // This is just a random url from a sample project
        let message = [
            "trackingUrl": "https://af6303be-0e1e-40b5-bb80-e1d9299cccff.ct0.app/e/tzgspbr4jcmcy1qkhw96m0034bvy"
        ]
        
        // Track delivery
        try await Courier.trackNotification(
            message: message,
            event: .delivered
        )
        
        // Track click
        try await Courier.trackNotification(
            message: message,
            event: .clicked
        )
        
        print("URL Tracked")

    }

    func testI() async throws {

        print("\n🔬 Testing Sign Out")

        try await Courier.shared.signOut()

        XCTAssertEqual(Courier.shared.fcmToken, fcmToken)
        XCTAssertEqual(Courier.shared.apnsToken, rawApnsToken.string)
        XCTAssertEqual(Courier.shared.accessToken, nil)
        XCTAssertEqual(Courier.shared.userId, nil)

    }
    
}
