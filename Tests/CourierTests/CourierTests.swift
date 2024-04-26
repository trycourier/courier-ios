import XCTest
@testable import Courier_iOS

final class CourierTests: XCTestCase {
    
    // Fake Token Values
    let rawApnsToken = Data([110, 157, 218, 189, 21, 13, 6, 181, 101, 205, 146, 170, 48, 254, 173, 48, 181, 30, 113, 220, 237, 83, 213, 213, 237, 248, 254, 211, 130, 206, 45, 20])
    let fcmToken = "F15C9C75-D8D3-48A7-989F-889BEE3BE8D9"
    let expoToken = "ExponentPushToken[_Example_Token]"
    
    private func signInUser(shouldUseJWT: Bool = true) async throws {
        
        // Add listener. Just to make sure the listener is working
        
        let listener = Courier.shared.addAuthenticationListener { userId in
            print(userId ?? "No userId found")
        }
        
        // Sign the user out, if there is one
        
        if let _ = Courier.shared.userId {
            try await Courier.shared.signOut()
        }
        
        // Check if we need to use the access token
        
        if (shouldUseJWT) {
            
            let jwt = try await ExampleServer().generateJwt(
                authKey: Env.COURIER_AUTH_KEY,
                userId: Env.COURIER_USER_ID
            )
            
            try await Courier.shared.signIn(
                accessToken: jwt,
                userId: Env.COURIER_USER_ID
            )
            
            XCTAssertEqual(Courier.shared.userId, Env.COURIER_USER_ID)
            XCTAssertEqual(Courier.shared.accessToken, jwt)
            XCTAssertEqual(Courier.shared.clientKey, nil)
            
        } else {
            
            try await Courier.shared.signIn(
                accessToken: Env.COURIER_ACCESS_TOKEN,
                clientKey: Env.COURIER_CLIENT_KEY,
                userId: Env.COURIER_USER_ID
            )
            
            XCTAssertEqual(Courier.shared.userId, Env.COURIER_USER_ID)
            XCTAssertEqual(Courier.shared.accessToken, Env.COURIER_ACCESS_TOKEN)
            XCTAssertEqual(Courier.shared.clientKey, Env.COURIER_CLIENT_KEY)
            
        }
        
        // Remove the listener
        
        listener.remove()
        
    }
    
    func testAPNSTokenSyncBeforeAuth() async throws {
        
        print("\n🔬 Setting APNS Token before User")
        
        try await Courier.shared.signOut()
        
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
    
    func testOtherTokenSyncBeforeAuth() async throws {
        
        print("🔬 Setting Other Token before User")
        
        try await Courier.shared.signOut()
        
        try await Courier.shared.setToken(provider: .firebaseFcm, token: fcmToken)
        
        let fcmProviderToken = await Courier.shared.getToken(provider: .firebaseFcm)
        let fcmKeyToken = await Courier.shared.getToken(providerKey: "firebase-fcm")
        
        XCTAssertEqual(Courier.shared.accessToken, nil)
        XCTAssertEqual(Courier.shared.clientKey, nil)
        XCTAssertEqual(Courier.shared.userId, nil)
        XCTAssertEqual(fcmProviderToken, fcmToken)
        XCTAssertEqual(fcmKeyToken, fcmToken)
        
    }
    
    func testSignInWithAuthKey() async throws {
        
        print("\n🔬 Starting Courier SDK with JWT")
        
        Courier.shared.addAuthenticationListener { userId in
            print(userId ?? "No userId found")
        }
        
        try await Courier.shared.signOut()

        try await Courier.shared.signIn(
            accessToken: Env.COURIER_AUTH_KEY,
            clientKey: Env.COURIER_CLIENT_KEY,
            userId: Env.COURIER_USER_ID
        )

        XCTAssertEqual(Courier.shared.accessToken, Env.COURIER_AUTH_KEY)
        XCTAssertEqual(Courier.shared.userId, Env.COURIER_USER_ID)
        XCTAssertEqual(Courier.shared.clientKey, Env.COURIER_CLIENT_KEY)
        
    }
    
    func testAuth() async throws {
        
        print("🔬 Testing Authentication Limits")
        
        try await Courier.shared.signOut()
        
        try await Courier.shared.signIn(
            accessToken: Env.COURIER_AUTH_KEY,
            clientKey: Env.COURIER_CLIENT_KEY,
            userId: Env.COURIER_USER_ID
        )
        
        try await Courier.shared.signIn(
            accessToken: "different_token",
            clientKey: "different_key",
            userId: "different_id"
        )
        
        XCTAssertEqual(Courier.shared.accessToken, Env.COURIER_AUTH_KEY)
        XCTAssertEqual(Courier.shared.clientKey, Env.COURIER_CLIENT_KEY)
        XCTAssertEqual(Courier.shared.userId, Env.COURIER_USER_ID)
        
        try await Courier.shared.signOut()
        
    }
    
    func testSignInWithJWT() async throws {
        
        print("\n🔬 Starting Courier SDK with JWT")
        
        let jwt = try await ExampleServer().generateJwt(
            authKey: Env.COURIER_AUTH_KEY,
            userId: Env.COURIER_USER_ID
        )
        
        Courier.shared.addAuthenticationListener { userId in
            print(userId ?? "No userId found")
        }
        
        try await Courier.shared.signOut()

        try await Courier.shared.signIn(
            accessToken: jwt,
            userId: Env.COURIER_USER_ID
        )

        XCTAssertEqual(Courier.shared.accessToken, jwt)
        XCTAssertEqual(Courier.shared.userId, Env.COURIER_USER_ID)
        XCTAssertEqual(Courier.shared.clientKey, nil)
        
    }
    
    func testAPNSTokenSync() async throws {

        print("\n🔬 Testing APNS Token Update")
        
        try await signInUser()
        
        try await Courier.shared.setAPNSToken(rawApnsToken)
        
        let apnsToken = await Courier.shared.getAPNSToken()

        XCTAssertEqual(Courier.shared.accessToken != nil, true)
        XCTAssertEqual(Courier.shared.userId, Env.COURIER_USER_ID)
        XCTAssertEqual(apnsToken?.string, rawApnsToken.string)

    }

    func testOtherTokenSync() async throws {

        print("\n🔬 Testing FCM Token Update")
        
        try await signInUser()
        
        try await Courier.shared.setToken(provider: .firebaseFcm, token: fcmToken)
        let fcm = await Courier.shared.getToken(provider: .firebaseFcm)
        
        try await Courier.shared.setToken(provider: .expo, token: expoToken)
        let expo = await Courier.shared.getToken(provider: .expo)

        XCTAssertEqual(Courier.shared.accessToken != nil, true)
        XCTAssertEqual(Courier.shared.userId, Env.COURIER_USER_ID)
        XCTAssertEqual(fcm, fcmToken)
        XCTAssertEqual(expo, expoToken)

    }
    
    func testSendAPNSMessage() async throws {

        print("\n🔬 Testing Sending APNS Message")
        
        let _ = try await ExampleServer().sendTest(
            authKey: Env.COURIER_ACCESS_TOKEN,
            userId: Env.COURIER_USER_ID,
            key: "apn"
        )

    }
    
    func testSendFCMMessage() async throws {

        print("\n🔬 Testing Sending FCM Message")
        
        let _ = try await ExampleServer().sendTest(
            authKey: Env.COURIER_ACCESS_TOKEN,
            userId: Env.COURIER_USER_ID,
            key: "firebase-fcm"
        )

    }
    
    func testTrackPushMessage() async throws {

        print("\n🔬 Testing Tracking URL")
        
        // This is just an enxample tracking url
        // You can find urls like this in the message payload send in the push
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
    
    func loadAllInboxMessages() async throws -> CourierInboxListener {
        
        var shouldHold = true
        var error: String? = nil {
            didSet {
                shouldHold = false
            }
        }
        var canPage = true {
            didSet {
                shouldHold = false
            }
        }
        
        let listener = Courier.shared.addInboxListener(
            onInitialLoad: {
                print("Loading Inbox")
            },
            onError: { e in
                print(e)
                error = String(describing: e)
            },
            onMessagesChanged: { messages, unreadMessageCount, totalMessageCount, canPaginate in
                canPage = canPaginate
                print(messages)
            }
        )
        
        // Hold while can page
        while (shouldHold) {}
        
        // Get new pages
        while (canPage) {
            
            XCTAssertEqual(error, nil)
            
            try await Courier.shared.fetchNextPageOfMessages()
            
        }
        
        let messages = await Courier.shared.getInboxMessages()
        
        print("Total Inbox Messages: \(messages?.count ?? 0)")
        
        return listener
        
    }
    
    func testInboxListener() async throws {

        print("\n🔬 Testing Inbox Get Messages")
        
        try await signInUser()
        
        let listener = try await loadAllInboxMessages()
        
        let messages = await Courier.shared.getInboxMessages()
        
        XCTAssertNotNil(messages)
        
        listener.remove()

    }
    
    func testInboxListenerWithAuth() async throws {

        print("\n🔬 Testing Inbox Auth States")
        
        Courier.shared.isDebugging = false
        
        try await Courier.shared.signOut()
        
        // 0. Add a listener
        Courier.shared.addInboxListener(
            onInitialLoad: {
                print("onInitialLoad 1")
            },
            onError: { e in
                print("onError 1")
            },
            onMessagesChanged: { messages, unreadMessageCount, totalMessageCount, canPaginate in
                print("onMessagesChanged 1")
            }
        )
        
        // 1. Sign user in
        try await signInUser()
        
        // 2. Add another listener
        var isLoading = true
        
        Courier.shared.addInboxListener(
            onInitialLoad: {
                print("onInitialLoad 2")
                isLoading = true
            },
            onError: { e in
                print("onError 2")
            },
            onMessagesChanged: { messages, unreadMessageCount, totalMessageCount, canPaginate in
                print("onMessagesChanged 2")
                isLoading = false
            }
        )
        
        // 3. Sign user in again
        try await signInUser()
        
        while (isLoading) {
            // Empty
        }
        
        Courier.shared.removeAllInboxListeners()
        
        Courier.shared.isDebugging = true

    }
    
    func testReadMessage() async throws {

        print("\n🔬 Testing Read Message")
        
        let messageId = try await ExampleServer().sendTest(
            authKey: Env.COURIER_ACCESS_TOKEN,
            userId: Env.COURIER_USER_ID,
            key: "inbox"
        )
        
        try await signInUser()
        
        try await Courier.shared.readMessage(
            messageId: messageId
        )
        
    }
    
    func testClickMessage() async throws {

        print("\n🔬 Testing Click Message")
        
        try await signInUser()
        
        // Get all the messages
        let listener = try await loadAllInboxMessages()
        
        // Find the first message
        // Needed because we need to ensure the inbox ref has data
        let messages = await Courier.shared.getInboxMessages()
        let firstMessage = messages?.first
        
        // Click the message
        try await Courier.shared.clickMessage(
            messageId: firstMessage!.messageId
        )
        
        listener.remove()

    }
    
    func testUnreadMessage() async throws {

        print("\n🔬 Testing Unread Message")
        
        let messageId = try await ExampleServer().sendTest(
            authKey: Env.COURIER_ACCESS_TOKEN,
            userId: Env.COURIER_USER_ID,
            key: "inbox"
        )
        
        try await signInUser()
        
        try await Courier.shared.unreadMessage(
            messageId: messageId
        )

    }
    
    func testTrackInboxMessage() async throws {

        print("\n🔬 Testing Read Message")
        
        let messageId = try await ExampleServer().sendTest(
            authKey: Env.COURIER_ACCESS_TOKEN,
            userId: Env.COURIER_USER_ID,
            key: "inbox"
        )
        
        try await signInUser()
        
        try await Courier.shared.readMessage(
            messageId: messageId
        )
        
    }
    
    func testOpenInboxMessage() async throws {

        print("\n🔬 Testing Open Message")
        
        let messageId = try await ExampleServer().sendTest(
            authKey: Env.COURIER_ACCESS_TOKEN,
            userId: Env.COURIER_USER_ID,
            key: "inbox"
        )
        
        try await signInUser()
        
        try await InboxRepository().openMessage(
            clientKey: Env.COURIER_CLIENT_KEY,
            userId: Env.COURIER_USER_ID,
            messageId: messageId
        )

    }
    
    func testInboxPaginationLimits() async throws {

        print("\n🔬 Setting Inbox Pagination Limit")
        
        try await Courier.shared.signOut()

        Courier.shared.inboxPaginationLimit = 10
        XCTAssertEqual(Courier.shared.inboxPaginationLimit, 10)

        Courier.shared.inboxPaginationLimit = -1000
        XCTAssertEqual(Courier.shared.inboxPaginationLimit, 1)

        Courier.shared.inboxPaginationLimit = 1000
        XCTAssertEqual(Courier.shared.inboxPaginationLimit, 100)

    }
    
    func testGetBrand() async throws {

        print("\n🔬 Testing Get Brand")
        
        try await signInUser()

        let brand = try await BrandsRepository().getBrand(
            clientKey: Env.COURIER_CLIENT_KEY,
            userId: Env.COURIER_USER_ID,
            brandId: "EK44JHXWFX4A9AGC8QWVNTBDTKC2"
        )
        
        print(brand)

    }
    
    func testGetUserPreferences() async throws {

        print("\n🔬 Get User Preferences")
        
        try await signInUser()
        
        let preferences = try await Courier.shared.getUserPreferences()
        
        XCTAssertEqual(preferences.items.isEmpty, false)

    }
    
    func testUpdateUserPreference() async throws {

        print("\n🔬 Put User Preference Topic")
        
        try await signInUser()
        
        try await Courier.shared.putUserPreferencesTopic(
            topicId: "VFPW1YD8Y64FRYNVQCKC9QFQCFVF",
            status: .optedOut,
            hasCustomRouting: true,
            customRouting: [.sms, .push]
        )

    }
    
    func testGetUserPreferenceTopic() async throws {

        print("\n🔬 Get User Preference Topic")
        
        try await signInUser()

        let topic = try await Courier.shared.getUserPreferencesTopic(
            topicId: "VFPW1YD8Y64FRYNVQCKC9QFQCFVF"
        )
        
        XCTAssertEqual(topic.customRouting, [.sms, .push])

    }
    
    func testErrors() async throws {
        
        print("\n🔬 Testing Errors")
        
        do {
            
            try await Courier.shared.signOut()
            
            try await Courier.shared.signIn(accessToken: "", userId: "")
            
            try await Courier.shared.setToken(providerKey: "", token: "something")
            
        } catch let error as CourierError {
            
            XCTAssertEqual(error.message, "Unauthorized")
            
        }

    }

    func testSignOut() async throws {

        print("\n🔬 Testing Sign Out")
        
        Courier.shared.addAuthenticationListener { userId in
            print(userId ?? "No userId found")
        }

        try await Courier.shared.signOut()
        
        let apns = await Courier.shared.getAPNSToken()
        let fcm = await Courier.shared.getToken(providerKey: "firebase-fcm")
        let expo = await Courier.shared.getToken(provider: .expo)
        let oneSignal = await Courier.shared.getToken(provider: .oneSignal)

        XCTAssertEqual(Courier.shared.accessToken, nil)
        XCTAssertEqual(Courier.shared.clientKey, nil)
        XCTAssertEqual(Courier.shared.userId, nil)
        XCTAssertEqual(fcm, fcmToken)
        XCTAssertEqual(expo, expoToken)
        XCTAssertEqual(oneSignal, nil)
        XCTAssertEqual(apns?.string, rawApnsToken.string)

    }
    
}
