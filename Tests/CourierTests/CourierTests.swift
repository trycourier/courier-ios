import XCTest
@testable import Courier_iOS

final class CourierTests: XCTestCase {
    
    // Fake Token Values
    let rawApnsToken = Data([110, 157, 218, 189, 21, 13, 6, 181, 101, 205, 146, 170, 48, 254, 173, 48, 181, 30, 113, 220, 237, 83, 213, 213, 237, 248, 254, 211, 130, 206, 45, 20])
    let fcmToken = "F15C9C75-D8D3-48A7-989F-889BEE3BE8D9"
    
    func testA_setAPNSTokenBeforeAuth() async throws {
        
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
    
    func testB_setFCMTokenBeforeAuth() async throws {
        
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
    
    func testC_signInWithAuthKey() async throws {
        
        print("\n🔬 Starting Courier SDK with JWT")
        
        Courier.shared.addAuthenticationListener { userId in
            print(userId ?? "No userId found")
        }

        try await Courier.shared.signIn(
            accessToken: Env.COURIER_ACCESS_TOKEN,
            userId: Env.COURIER_USER_ID
        )

        XCTAssertEqual(Courier.shared.accessToken, Env.COURIER_ACCESS_TOKEN)
        XCTAssertEqual(Courier.shared.userId, Env.COURIER_USER_ID)
        XCTAssertEqual(Courier.shared.clientKey, nil)
        
    }
    
    func testD_signInWithJWT() async throws {
        
        print("\n🔬 Starting Courier SDK with JWT")
        
        let jwt = try await ExampleServer().generateJwt(
            authKey: Env.COURIER_AUTH_KEY,
            userId: Env.COURIER_USER_ID
        )
        
        Courier.shared.addAuthenticationListener { userId in
            print(userId ?? "No userId found")
        }

        try await Courier.shared.signIn(
            accessToken: jwt,
            clientKey: Env.COURIER_CLIENT_KEY,
            userId: Env.COURIER_USER_ID
        )

        XCTAssertEqual(Courier.shared.accessToken, jwt)
        XCTAssertEqual(Courier.shared.userId, Env.COURIER_USER_ID)
        XCTAssertEqual(Courier.shared.clientKey, Env.COURIER_CLIENT_KEY)
        
    }
    
    func testE_setAPNSToken() async throws {

        print("\n🔬 Testing APNS Token Update")
        
        try await Courier.shared.setAPNSToken(rawApnsToken)

        XCTAssertEqual(Courier.shared.accessToken != nil, true)
        XCTAssertEqual(Courier.shared.userId, Env.COURIER_USER_ID)
        XCTAssertEqual(Courier.shared.apnsToken, rawApnsToken.string)

    }

    func testF_setFCMToken() async throws {

        print("\n🔬 Testing FCM Token Update")
        
        try await Courier.shared.setFCMToken(fcmToken)

        XCTAssertEqual(Courier.shared.accessToken != nil, true)
        XCTAssertEqual(Courier.shared.userId, Env.COURIER_USER_ID)
        XCTAssertEqual(Courier.shared.fcmToken, fcmToken)

    }
    
    func testG_sendAPNSMessage() async throws {

        print("\n🔬 Testing Sending APNS Message")
        
        let title = "APNS message sent"
        let body = "Hello from Xcode tests 👋"
        
        let requestId = try await Courier.shared.sendMessage(
            authKey: Env.COURIER_ACCESS_TOKEN,
            userIds: [Env.COURIER_USER_ID],
            title: title,
            body: body,
            channels: [
                ApplePushNotificationsServiceChannel(
                    aps: [
                        "alert": [
                            "title": title,
                            "body": body
                        ],
                        "sound": "ping.aiff",
                        "badge": 123,
                        "CUSTOM_NUMBER": 456,
                        "CUSTOM_BOOLEAN": true,
                        "CUSTOM_KEY": "YOUR_CUSTOM_VALUE"
                    ]
                )
            ]
        )
        
        print("Request ID: \(requestId)")

        XCTAssertEqual(requestId.isEmpty, false)

    }
    
    func testH_sendFCMMessage() async throws {

        print("\n🔬 Testing Sending FCM Message")
        
        let requestId = try await Courier.shared.sendMessage(
            authKey: Env.COURIER_ACCESS_TOKEN,
            userIds: [Env.COURIER_USER_ID],
            title: "FCM message sent",
            body: "Hello from Xcode tests 👋",
            channels: [
                FirebaseCloudMessagingChannel(
                    data: [
                        "FCM_CUSTOM_KEY": "YOUR_CUSTOM_VALUE",
                    ],
                    aps: [
                        "sound": "ping.aiff",
                        "badge": 123,
                        "APNS_CUSTOM_NUMBER": 456,
                        "APNS_CUSTOM_BOOLEAN": true,
                        "APNS_CUSTOM_KEY": "YOUR_CUSTOM_VALUE"
                    ]
                )
            ]
        )
        
        print("Request ID: \(requestId)")

        XCTAssertEqual(requestId.isEmpty, false)

    }
    
    func testI_trackPushNotification() async throws {

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

    }
    
    private var exampleMessageId: String? = nil
    
    func testJ_inboxListener() async throws {

        print("\n🔬 Testing Inbox Get Messages")
        
        var canPage = true
        var error: String? = nil
        
        let listener = Courier.shared.addInboxListener(
            onInitialLoad: {
                print("Loading")
            },
            onError: { e in
                print(e)
                error = String(describing: e)
            },
            onMessagesChanged: { messages, unreadMessageCount, totalMessageCount, canPaginate in
                canPage = canPaginate
            }
        )
        
        while (canPage && error != nil) {
            try await Courier.shared.fetchNextPageOfMessages()
        }
        
        // Set an example message id
        exampleMessageId = Courier.shared.inboxMessages?.first?.messageId
        
        listener.remove()
        
        XCTAssertEqual(error, nil)

    }
    
    func testK_readMessage() async throws {

        print("\n🔬 Testing Read Message")
        
        guard let messageId = exampleMessageId else {
            return
        }
        
        try await InboxRepository().readMessage(
            clientKey: Env.COURIER_CLIENT_KEY,
            userId: Env.COURIER_USER_ID,
            messageId: messageId
        )

    }
    
    func testL_unreadMessage() async throws {

        print("\n🔬 Testing Read Message")
        
        guard let messageId = exampleMessageId else {
            return
        }
        
        try await InboxRepository().unreadMessage(
            clientKey: Env.COURIER_CLIENT_KEY,
            userId: Env.COURIER_USER_ID,
            messageId: messageId
        )

    }
    
    func testM_openMessage() async throws {

        print("\n🔬 Testing Read Message")
        
        guard let messageId = exampleMessageId else {
            return
        }
        
        try await InboxRepository().openMessage(
            clientKey: Env.COURIER_CLIENT_KEY,
            userId: Env.COURIER_USER_ID,
            messageId: messageId
        )

    }
    
    func testN_sendInboxMessage() async throws {

        print("\n🔬 Testing Sending Inbox Message")
        
        let requestId = try await Courier.shared.sendMessage(
            authKey: Env.COURIER_ACCESS_TOKEN,
            userIds: [Env.COURIER_USER_ID],
            title: "🐤 Inbox Message",
            body: "Message sent from Xcode tests",
            channels: [
                CourierInboxChannel(
                    elements: [
                        CourierElement(
                            type: "action",
                            content: "Button 1",
                            data: [
                                "CUSTOM_KEY": "YOUR_CUSTOM_VALUE"
                            ]
                        ),
                        CourierElement(
                            type: "action",
                            content: "Button 2",
                            data: [
                                "CUSTOM_KEY": "YOUR_CUSTOM_VALUE"
                            ]
                        )
                    ]
                )
            ]
        )
        
        print("Request ID: \(requestId)")

        XCTAssertEqual(requestId.isEmpty, false)

    }
    
    func testO_paginationChecks() async throws {

        print("\n🔬 Setting Inbox Pagination Limit")

        Courier.shared.inboxPaginationLimit = 10
        XCTAssertEqual(Courier.shared.inboxPaginationLimit, 10)

        Courier.shared.inboxPaginationLimit = -1000
        XCTAssertEqual(Courier.shared.inboxPaginationLimit, 1)

        Courier.shared.inboxPaginationLimit = 1000
        XCTAssertEqual(Courier.shared.inboxPaginationLimit, 200)

    }
    
    func testP_getBrand() async throws {

        print("\n🔬 Testing Get Brand")

        let brand = try await BrandsRepository().getBrand(
            clientKey: Env.COURIER_CLIENT_KEY,
            userId: Env.COURIER_USER_ID,
            brandId: "EK44JHXWFX4A9AGC8QWVNTBDTKC2"
        )
        
        print(brand)

    }

    func testQ_signOut() async throws {

        print("\n🔬 Testing Sign Out")
        
        Courier.shared.addAuthenticationListener { userId in
            print(userId ?? "No userId found")
        }

        try await Courier.shared.signOut()

        XCTAssertEqual(Courier.shared.accessToken, nil)
        XCTAssertEqual(Courier.shared.clientKey, nil)
        XCTAssertEqual(Courier.shared.userId, nil)
        XCTAssertEqual(Courier.shared.fcmToken, fcmToken)
        XCTAssertEqual(Courier.shared.apnsToken, rawApnsToken.string)

    }
    
}
