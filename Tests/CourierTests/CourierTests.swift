import XCTest
@testable import Courier

final class CourierTests: XCTestCase {
    
    private let apnsToken = "282D849F-2AF8-4ECB-BBFD-EC3F96DD59D4"
    private let fcmToken = "F15C9C75-D8D3-48A7-989F-889BEE3BE8D9"
    private let userId = "example_user"
    private let testAuthKey = "pk_prod_EYP5JB2DH447WDJN7ACKPY75BEGJ"
    
    override func tearDown() async throws {
        print("\n")
    }
    
    func testA() async throws {

        print("\n🔬 Setting APNS Token before User")
        
        do {
            try await Courier.shared.setAPNSToken(apnsToken)
        } catch {
            XCTAssertEqual(Courier.shared.accessToken, nil)
            XCTAssertEqual(Courier.shared.userId, nil)
            XCTAssertEqual(Courier.shared.apnsToken, apnsToken)
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

        print("\n🔬 Starting Courier SDK")

        // Get the token from our custom endpoint
        // This should be your custom endpoint
        let accessToken = try await ExampleServer.generateJwt(userId: userId)

        // Set the access token and start the SDK
        try await Courier.shared.setCredentials(
            accessToken: accessToken,
            userId: userId
        )

        XCTAssertEqual(Courier.shared.accessToken, accessToken)
        XCTAssertEqual(Courier.shared.userId, userId)
        XCTAssertEqual(Courier.shared.apnsToken, apnsToken)
        XCTAssertEqual(Courier.shared.fcmToken, fcmToken)

    }
    
    func testE() async throws {

        print("\n🔬 Testing APNS Token Update")
        
        try await Courier.shared.setPushToken(
            provider: .apns,
            token: apnsToken
        )

        XCTAssertEqual(Courier.shared.accessToken != nil, true)
        XCTAssertEqual(Courier.shared.userId, userId)
        XCTAssertEqual(Courier.shared.fcmToken, fcmToken)

    }

    func testF() async throws {

        print("\n🔬 Testing FCM Token Update")
        
        try await Courier.shared.setPushToken(
            provider: .fcm,
            token: fcmToken
        )

        XCTAssertEqual(Courier.shared.accessToken != nil, true)
        XCTAssertEqual(Courier.shared.userId, userId)
        XCTAssertEqual(Courier.shared.fcmToken, fcmToken)

    }
    
    func testG() async throws {

        print("\n🔬 Testing Sending Test Message")
        
        // DO NOT STORE YOUR AUTH KEY IN THE PROJECT
        // THIS IS ONLY USED FOR TESTING
        let requestId = try await Courier.shared.sendPush(
            authKey: testAuthKey,
            userId: userId,
            title: "Hello!",
            message: "Chirp Chrip"
        )
        
        print("Request ID: \(requestId)")

        XCTAssertEqual(requestId.isEmpty, false)

    }

    func testH() async throws {

        print("\n🔬 Testing Sign Out")

        try await Courier.shared.signOut()

        XCTAssertEqual(Courier.shared.fcmToken, fcmToken)
        XCTAssertEqual(Courier.shared.apnsToken, apnsToken)
        XCTAssertEqual(Courier.shared.accessToken, nil)
        XCTAssertEqual(Courier.shared.userId, nil)

    }
    
}
