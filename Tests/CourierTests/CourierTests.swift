import XCTest
@testable import Courier

final class CourierTests: XCTestCase {
    
    let apnsToken = "282D849F-2AF8-4ECB-BBFD-EC3F96DD59D4"
    let fcmToken = "F15C9C75-D8D3-48A7-989F-889BEE3BE8D9"
    let userId = "example_user"
    
    func testA() async throws {

        print("🔬 Setting APNS Token before User")
        
        do {
            try await Courier.shared.setAPNSToken(apnsToken)
        } catch {
            XCTAssertEqual(Courier.shared.accessToken, nil)
            XCTAssertEqual(Courier.shared.userProfile?.id, nil)
            XCTAssertEqual(Courier.shared.apnsToken, apnsToken)
        }

    }
    
    func testB() async throws {

        print("🔬 Setting FCM Token before User")
        
        do {
            try await Courier.shared.setFCMToken(fcmToken)
        } catch {
            XCTAssertEqual(Courier.shared.accessToken, nil)
            XCTAssertEqual(Courier.shared.userProfile?.id, nil)
            XCTAssertEqual(Courier.shared.fcmToken, fcmToken)
        }

    }
    
    func testC() async throws {

        print("🔬 Starting Courier SDK")

        // Get the token from our custom endpoint
        // This should be your custom endpoint
        let accessToken = try await ExampleServer.generateJwt(userId: userId)

        // Create an example user
        let address = CourierAddress(
            formatted: "some_format",
            street_address: "1234 Fake Street",
            locality: "en-us",
            region: "east",
            postal_code: "55555",
            country: "us"
        )

        let user = CourierUserProfile(
            id: userId,
            email: "example@email.com",
            email_verified: false,
            phone_number: "5555555555",
            phone_number_verified: false,
            picture: "something.com",
            birthdate: "1/23/4567",
            gender: "gender",
            profile: "profile_name",
            sub: "sub",
            name: "Name",
            nickname: "Nickname",
            preferred_name: "Preferred Name",
            preferred_username: "Preferred Username",
            given_name: "Given Name",
            middle_name: "Middle Name",
            family_name: "Family Name",
            first_name: "First Name",
            last_name: "Last Name",
            website: "Website",
            locale: "Locale",
            zoneinfo: "Zoneinfo",
            updated_at: "Updated at now",
            address: address
        )

        // Set the access token and start the SDK
        try await Courier.shared.setUserProfile(
            accessToken: accessToken,
            userProfile: user
        )

        XCTAssertEqual(Courier.shared.accessToken != nil, true)
        XCTAssertEqual(Courier.shared.userProfile?.id, userId)
        XCTAssertEqual(Courier.shared.userProfile?.address?.street_address, "1234 Fake Street")
        XCTAssertEqual(Courier.shared.apnsToken, apnsToken)
        XCTAssertEqual(Courier.shared.fcmToken, fcmToken)

    }
    
    func testE() async throws {

        print("🔬 Testing APNS Token Update")
        
        try await Courier.shared.setPushToken(
            provider: .apns,
            token: apnsToken
        )

        XCTAssertEqual(Courier.shared.accessToken != nil, true)
        XCTAssertEqual(Courier.shared.userProfile?.id, userId)
        XCTAssertEqual(Courier.shared.fcmToken, fcmToken)

    }

    func testF() async throws {

        print("🔬 Testing FCM Token Update")
        
        try await Courier.shared.setPushToken(
            provider: .fcm,
            token: fcmToken
        )

        XCTAssertEqual(Courier.shared.accessToken != nil, true)
        XCTAssertEqual(Courier.shared.userProfile?.id, userId)
        XCTAssertEqual(Courier.shared.fcmToken, fcmToken)

    }
    
    func testG() async throws {

        print("🔬 Testing Sending Test Message")
        
        // DO NOT STORE YOUR AUTH KEY IN THE PROJECT
        // THIS IS ONLY USED FOR TESTING
        let requestId = try await Courier.shared.sendPush(
            authKey: "pk_prod_3EH7GNYRC9409PMQGRQE37GC6ABP",
            userId: userId,
            title: "Hello!",
            message: "Chirp Chrip"
        )
        
        print("Request ID: \(requestId)")

        XCTAssertEqual(requestId.isEmpty, false)

    }

    func testH() async throws {

        print("🔬 Testing Sign Out")

        try await Courier.shared.signOut()

        XCTAssertEqual(Courier.shared.fcmToken, fcmToken)
        XCTAssertEqual(Courier.shared.apnsToken, apnsToken)
        XCTAssertEqual(Courier.shared.accessToken, nil)
        XCTAssertEqual(Courier.shared.userProfile?.id, nil)

    }
    
}
