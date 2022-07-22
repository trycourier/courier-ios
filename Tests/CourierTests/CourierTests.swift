import XCTest
@testable import Courier

@available(iOS 10.0.0, *)
final class CourierTests: XCTestCase {
    
    let authKey = "pk_prod_3EH7GNYRC9409PMQGRQE37GC6ABP"
    let apnsToken = "282D849F-2AF8-4ECB-BBFD-EC3F96DD59D4"
    let fcmToken = "F15C9C75-D8D3-48A7-989F-889BEE3BE8D9"
    let userId = "example_id"
    
    func testA() throws {

        print("🔬 Testing SDK init")
        
        Courier.shared.authorizationKey = authKey
        
        XCTAssertEqual(Courier.shared.authorizationKey, authKey)

    }
    
    func testB() throws {

        print("🔬 Testing Setting APNS Token before User")

        let expectation = self.expectation(description: "Token not set")
        
        var didSucceed = false
        
        Courier.shared.setAPNSToken(
            apnsToken,
            onSuccess: {
                didSucceed = true
                expectation.fulfill()
            },
            onFailure: {
                didSucceed = false
                expectation.fulfill()
            })

        wait(for: [expectation], timeout: 10)
        
        XCTAssertEqual(Courier.shared.user?.id, nil)
        XCTAssertEqual(didSucceed, false)

    }
    
    func testC() throws {

        print("🔬 Testing Setting FCM Token before User")

        let expectation = self.expectation(description: "Token not set")
        
        var didSucceed = false
        
        Courier.shared.setFCMToken(
            apnsToken,
            onSuccess: {
                didSucceed = true
                expectation.fulfill()
            },
            onFailure: {
                didSucceed = false
                expectation.fulfill()
            })

        wait(for: [expectation], timeout: 10)
        
        XCTAssertEqual(Courier.shared.user?.id, nil)
        XCTAssertEqual(didSucceed, false)

    }
    
    func testD() throws {

        print("🔬 Testing Setting User")

        let expectation = self.expectation(description: "Updated User")
        
        let address = CourierAddress(
            formatted: "some_format",
            street_address: "1234 Fake Street",
            locality: "en-us",
            region: "east",
            postal_code: "55555",
            country: "us"
        )
        
        let user = CourierUser(
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
        
        Courier.shared.setUser(
            user,
            onSuccess: {
                expectation.fulfill()
            },
            onFailure: {
                expectation.fulfill()
            })

        wait(for: [expectation], timeout: 10)
        
        XCTAssertEqual(Courier.shared.user?.id, userId)
        XCTAssertEqual(Courier.shared.apnsToken, apnsToken)

    }
    
    func testE() throws {

        print("🔬 Testing APNS Token Update")

        let expectation = self.expectation(description: "Updating User APNS Token")
        
        var didSucceed = false
        
        Courier.shared.setAPNSToken(
            apnsToken,
            onSuccess: {
                didSucceed = true
                expectation.fulfill()
            },
            onFailure: {
                didSucceed = false
                expectation.fulfill()
            })

        wait(for: [expectation], timeout: 10)
        
        XCTAssertEqual(Courier.shared.apnsToken, apnsToken)
        XCTAssertEqual(didSucceed, true)

    }
    
    func testF() throws {

        print("🔬 Testing FCM Token Update")

        let expectation = self.expectation(description: "Updating User FCM Token")
        
        var didSucceed = false
        
        Courier.shared.setFCMToken(
            fcmToken,
            onSuccess: {
                didSucceed = true
                expectation.fulfill()
            },
            onFailure: {
                didSucceed = false
                expectation.fulfill()
            })

        wait(for: [expectation], timeout: 10)
        
        XCTAssertEqual(Courier.shared.apnsToken, apnsToken)
        XCTAssertEqual(Courier.shared.fcmToken, fcmToken)
        XCTAssertEqual(didSucceed, true)

    }
    
    func testG() throws {

        print("🔬 Testing Sign Out")

        let expectation = self.expectation(description: "Signing Out User")
        
        var didSucceed = false

        Courier.shared.signOut(
            onSuccess: {
                didSucceed = true
                expectation.fulfill()
            },
            onFailure: {
                didSucceed = false
                expectation.fulfill()
            })

        wait(for: [expectation], timeout: 10)
        
        XCTAssertEqual(Courier.shared.fcmToken, fcmToken)
        XCTAssertEqual(Courier.shared.apnsToken, apnsToken)
        XCTAssertEqual(Courier.shared.user?.id, nil)
        XCTAssertEqual(didSucceed, true)

    }
    
}
