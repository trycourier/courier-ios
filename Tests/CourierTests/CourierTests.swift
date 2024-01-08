import XCTest
@testable import Courier_iOS

final class CourierTests: XCTestCase {
    
    // Fake Token Values
    let rawApnsToken = Data([110, 157, 218, 189, 21, 13, 6, 181, 101, 205, 146, 170, 48, 254, 173, 48, 181, 30, 113, 220, 237, 83, 213, 213, 237, 248, 254, 211, 130, 206, 45, 20])
    let fcmToken = "F15C9C75-D8D3-48A7-989F-889BEE3BE8D9"
    
    func testA_setAPNSTokenBeforeAuth() async throws {
        
        print("\n🔬 Setting APNS Token before User")
        
        // Empty
        try await Courier.shared.setToken(provider: CourierPushProvider.apn, token: "")
        try await Courier.shared.setToken(providerKey: "", token: rawApnsToken.string)
        
        // Valid
        try await Courier.shared.setAPNSToken(rawApnsToken)
        
        // Get the current APNS token
        let apnsToken = await Courier.shared.getAPNSToken()
        let providerApnsToken = await Courier.shared.getToken(provider: .apn)
        
        XCTAssertEqual(Courier.shared.accessToken, nil)
        XCTAssertEqual(Courier.shared.clientKey, nil)
        XCTAssertEqual(Courier.shared.userId, nil)
        XCTAssertEqual(apnsToken, rawApnsToken)
        XCTAssertEqual(apnsToken?.string, rawApnsToken.string)
        XCTAssertEqual(providerApnsToken, rawApnsToken.string)

    }
    
    func testB_setFCMTokenBeforeAuth() async throws {
        
        print("🔬 Setting FCM Token before User")
        
        try await Courier.shared.setToken(provider: .firebaseFcm, token: fcmToken)
        
        let fcmProviderToken = await Courier.shared.getToken(provider: .firebaseFcm)
        let fcmKeyToken = await Courier.shared.getToken(providerKey: "firebase-fcm")
        
        XCTAssertEqual(Courier.shared.accessToken, nil)
        XCTAssertEqual(Courier.shared.clientKey, nil)
        XCTAssertEqual(Courier.shared.userId, nil)
        XCTAssertEqual(fcmProviderToken, fcmToken)
        XCTAssertEqual(fcmKeyToken, fcmToken)
        
    }
    
    func testC_signInWithAuthKey() async throws {
        
        print("\n🔬 Starting Courier SDK with JWT")
        
        Courier.shared.addAuthenticationListener { userId in
            print(userId ?? "No userId found")
        }

        try await Courier.shared.signIn(
            accessToken: Env.COURIER_AUTH_KEY,
            userId: Env.COURIER_USER_ID
        )

        XCTAssertEqual(Courier.shared.accessToken, Env.COURIER_AUTH_KEY)
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
        
        let apnsToken = await Courier.shared.getAPNSToken()

        XCTAssertEqual(Courier.shared.accessToken != nil, true)
        XCTAssertEqual(Courier.shared.userId, Env.COURIER_USER_ID)
        XCTAssertEqual(apnsToken?.string, rawApnsToken.string)

    }

    func testF_setFCMToken() async throws {

        print("\n🔬 Testing FCM Token Update")
        
        try await Courier.shared.setToken(provider: .firebaseFcm, token: fcmToken)
        
        let fcm = await Courier.shared.getToken(provider: .firebaseFcm)

        XCTAssertEqual(Courier.shared.accessToken != nil, true)
        XCTAssertEqual(Courier.shared.userId, Env.COURIER_USER_ID)
        XCTAssertEqual(fcm, fcmToken)

    }
    
    func testG_sendAPNSMessage() async throws {

        print("\n🔬 Testing Sending APNS Message")
        
        let _ = try await ExampleServer().sendTest(
            authKey: Env.COURIER_ACCESS_TOKEN,
            userId: Env.COURIER_USER_ID,
            key: "apn"
        )

    }
    
    func testH_sendFCMMessage() async throws {

        print("\n🔬 Testing Sending FCM Message")
        
        let _ = try await ExampleServer().sendTest(
            authKey: Env.COURIER_ACCESS_TOKEN,
            userId: Env.COURIER_USER_ID,
            key: "firebase-fcm"
        )

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

        print("\n🔬 Testing Unread Message")
        
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

        print("\n🔬 Testing Open Message")
        
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
        
        let _ = try await ExampleServer().sendTest(
            authKey: Env.COURIER_ACCESS_TOKEN,
            userId: Env.COURIER_USER_ID,
            key: "inbox"
        )

    }
    
    func testO_paginationChecks() async throws {

        print("\n🔬 Setting Inbox Pagination Limit")

        Courier.shared.inboxPaginationLimit = 10
        XCTAssertEqual(Courier.shared.inboxPaginationLimit, 10)

        Courier.shared.inboxPaginationLimit = -1000
        XCTAssertEqual(Courier.shared.inboxPaginationLimit, 1)

        Courier.shared.inboxPaginationLimit = 1000
        XCTAssertEqual(Courier.shared.inboxPaginationLimit, 100)

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
    
    func testQ_getUserPreferences() async throws {

        print("\n🔬 Get User Preferences")
        
        let preferences = try await Courier.shared.getUserPreferences()
        
        XCTAssertEqual(preferences.items.isEmpty, false)

    }
    
    func testR_getUserPreferences() async throws {

        print("\n🔬 Put User Preference Topic")
        
        try await Courier.shared.putUserPreferencesTopic(
            topicId: "3PBVT6GFEVMDRHKQ3YGVFRCEV68M",
            status: .optedOut,
            hasCustomRouting: true,
            customRouting: [.sms, .push]
        )

    }
    
    func testS_getUserPreferenceTopic() async throws {

        print("\n🔬 Get User Preference Topic")

        let topic = try await Courier.shared.getUserPreferencesTopic(
            topicId: "3PBVT6GFEVMDRHKQ3YGVFRCEV68M"
        )
        
        XCTAssertEqual(topic.customRouting, [.sms, .push])

    }

    func testZ_signOut() async throws {

        print("\n🔬 Testing Sign Out")
        
        Courier.shared.addAuthenticationListener { userId in
            print(userId ?? "No userId found")
        }

        try await Courier.shared.signOut()
        
        let apns = await Courier.shared.getAPNSToken()
        let fcm = await Courier.shared.getToken(providerKey: "firebase-fcm")
        let expo = await Courier.shared.getToken(provider: .expo)

        XCTAssertEqual(Courier.shared.accessToken, nil)
        XCTAssertEqual(Courier.shared.clientKey, nil)
        XCTAssertEqual(Courier.shared.userId, nil)
        XCTAssertEqual(fcm, fcmToken)
        XCTAssertEqual(expo, nil)
        XCTAssertEqual(apns?.string, rawApnsToken.string)

    }
    
}
