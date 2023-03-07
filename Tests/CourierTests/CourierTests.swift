import XCTest
@testable import Courier

let rawApnsToken = Data([110, 157, 218, 189, 21, 13, 6, 181, 101, 205, 146, 170, 48, 254, 173, 48, 181, 30, 113, 220, 237, 83, 213, 213, 237, 248, 254, 211, 130, 206, 45, 20]) // This is fake
let fcmToken = "F15C9C75-D8D3-48A7-989F-889BEE3BE8D9" // This is fake

final class CourierTests: XCTestCase {
    
    func test1() async throws {
        
        try await Courier.shared.signIn(
            accessToken: Env.COURIER_ACCESS_TOKEN,
            clientKey: Env.COURIER_CLIENT_KEY,
            userId: Env.COURIER_USER_ID
        )

        var canPage = true

        Courier.shared.addInboxListener(
            onInitialLoad: {
                print("L1 Loading")
            },
            onError: { error in
                print("L1 Error \(error)")
            },
            onMessagesChanged: { messages, unreadMessageCount, totalMessageCount, canPaginate  in
                print("L1 messages: \(messages.count) \(unreadMessageCount) \(totalMessageCount) \(canPaginate)")
                canPage = canPaginate
            })

        while (canPage) {
            try await Courier.shared.fetchNextPageOfMessages()
        }
        
    }
    
    func test2() async throws {
        
        let id = "1-64053eb4-d7e678c27e93946c16a1d587"
        
        try await Courier.shared.readMessage(messageId: id)
        
    }
    
    func test3() async throws {
        
        let id = "1-64053eb4-d7e678c27e93946c16a1d587"
        
        try await Courier.shared.unreadMessage(messageId: id)
        
    }
    
    func testA() async throws {
        
        print("\n🔬 Setting APNS Token before User")
        
        do {
            try await Courier.shared.setAPNSToken(rawApnsToken)
        } catch {
            XCTAssertEqual(Courier.shared.accessToken, nil)
            XCTAssertEqual(Courier.shared.clientKey, nil)
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
            XCTAssertEqual(Courier.shared.clientKey, nil)
            XCTAssertEqual(Courier.shared.userId, nil)
            XCTAssertEqual(Courier.shared.fcmToken, fcmToken)
        }

    }
    
    func testC() async throws {

        print("\n🔬 Starting Courier SDK with JWT")

        // Set the access token and start the SDK
        try await Courier.shared.signIn(
            accessToken: Env.COURIER_ACCESS_TOKEN,
            clientKey: Env.COURIER_CLIENT_KEY,
            userId: Env.COURIER_USER_ID
        )

        XCTAssertEqual(Courier.shared.accessToken, Env.COURIER_ACCESS_TOKEN)
        XCTAssertEqual(Courier.shared.userId, Env.COURIER_USER_ID)
        XCTAssertEqual(Courier.shared.apnsToken, rawApnsToken.string)
        XCTAssertEqual(Courier.shared.fcmToken, fcmToken)

    }
    
    func testD() async throws {

        print("\n🔬 Starting Courier SDK with Auth Key")
        
        // TODO: Remove this. For test purposed only
        // Set the access token and start the SDK
        try await Courier.shared.signIn(
            accessToken: Env.COURIER_ACCESS_TOKEN,
            clientKey: Env.COURIER_CLIENT_KEY,
            userId: Env.COURIER_USER_ID
        )

        XCTAssertEqual(Courier.shared.accessToken, Env.COURIER_ACCESS_TOKEN)
        XCTAssertEqual(Courier.shared.userId, Env.COURIER_USER_ID)
        XCTAssertEqual(Courier.shared.apnsToken, rawApnsToken.string)
        XCTAssertEqual(Courier.shared.fcmToken, fcmToken)

    }
    
    func testE() async throws {

        print("\n🔬 Testing APNS Token Update")
        
        try await Courier.shared.setAPNSToken(rawApnsToken)

        XCTAssertEqual(Courier.shared.accessToken != nil, true)
        XCTAssertEqual(Courier.shared.userId, Env.COURIER_USER_ID)
        XCTAssertEqual(Courier.shared.fcmToken, fcmToken)

    }

    func testF() async throws {

        print("\n🔬 Testing FCM Token Update")
        
        try await Courier.shared.setFCMToken(fcmToken)

        XCTAssertEqual(Courier.shared.accessToken != nil, true)
        XCTAssertEqual(Courier.shared.userId, Env.COURIER_USER_ID)
        XCTAssertEqual(Courier.shared.fcmToken, fcmToken)

    }
    
    func testG() async throws {

        print("\n🔬 Testing Sending APNS Message")
        
        // TODO: Remove this. For test purposed only
        // Do not use auth key in production app
        let requestId = try await Courier.shared.sendMessage(
            authKey: Env.COURIER_ACCESS_TOKEN,
            userId: Env.COURIER_USER_ID,
            title: "🐤 Chirp Chirp from APNS",
            message: "Message sent from Xcode tests",
            providers: [.apns]
        )
        
        print("Request ID: \(requestId)")

        XCTAssertEqual(requestId.isEmpty, false)

    }
    
    func testH() async throws {

        print("\n🔬 Testing Sending FCM Message")
        
        // TODO: Remove this. For test purposed only
        // Do not use auth key in production app
        let requestId = try await Courier.shared.sendMessage(
            authKey: Env.COURIER_ACCESS_TOKEN,
            userId: Env.COURIER_USER_ID,
            title: "🐤 Chirp Chirp from FCM!",
            message: "Message sent from Xcode tests",
            providers: [.fcm]
        )
        
        print("Request ID: \(requestId)")

        XCTAssertEqual(requestId.isEmpty, false)

    }
    
    func testI() async throws {

        print("\n🔬 Testing Tracking URL")
        
        // This is just a random url from a sample project
        let message = [
            "trackingUrl": "https://af6303be-0e1e-40b5-bb80-e1d9299cccff.ct0.app/t/tzgspbr4jcmcy1qkhw96m0034bvy"
        ]
        
        // Track delivery
        try await Courier.shared.trackNotification(
            message: message,
            event: .delivered
        )
        
        // Track click
        try await Courier.shared.trackNotification(
            message: message,
            event: .clicked
        )
        
        print("URL Tracked")

    }

    func testJ() async throws {

        print("\n🔬 Testing Sign Out")

        try await Courier.shared.signOut()

        XCTAssertEqual(Courier.shared.fcmToken, fcmToken)
        XCTAssertEqual(Courier.shared.apnsToken, rawApnsToken.string)
        XCTAssertEqual(Courier.shared.accessToken, nil)
        XCTAssertEqual(Courier.shared.userId, nil)

    }
    
    func testK() async throws {
        
        print("\n🔬 Setting Inbox Pagination Limit")
        
        Courier.shared.inboxPaginationLimit = 10
        XCTAssertEqual(Courier.shared.inboxPaginationLimit, 10)
        
        Courier.shared.inboxPaginationLimit = -1000
        XCTAssertEqual(Courier.shared.inboxPaginationLimit, 1)
        
        Courier.shared.inboxPaginationLimit = 1000
        XCTAssertEqual(Courier.shared.inboxPaginationLimit, 200)

    }
    
}
