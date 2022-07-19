import XCTest
@testable import Courier

final class CourierTests: XCTestCase {
    
    @available(iOS 10.0.0, *)
    func testSetAuthKey() throws {

        print("Starting SDK")

        Courier.shared.authorizationKey = "pk_prod_3EH7GNYRC9409PMQGRQE37GC6ABP"

        print("SDK Started")

    }
    
    @available(iOS 10.0.0, *)
    func testSetUser() throws {

        print("Setting User")

        let expectation = self.expectation(description: "Updated User")

        Courier.shared.taskManager.allTasksCompleted = {
            expectation.fulfill()
        }
        
        let address = CourierAddress(
            formatted: "some_format",
            street_address: "1234 Fake Street",
            locality: "en-us",
            region: "east",
            postal_code: "55555",
            country: "us"
        )
        
        Courier.shared.user = CourierUser(
            id: "example_1",
            email: "example@email.com",
            email_verified: false,
            phone_number: "5555555555",
            phone_number_verified: false,
            picture: "something.com",
            birthdate: "1/23/4567",
            gender: "gender",
            profile: "profile_name",
            sub: "sub_name",
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

        wait(for: [expectation], timeout: 10)

        print("User Set")

    }
    
//    @available(iOS 10.0.0, *)
//    func testSignOut() throws {
//
//        print("Testing Signout")
//
//        let expectation = self.expectation(description: "Updating User")
//
//        Courier.shared.signOut {
//            expectation.fulfill()
//        }
//
//        wait(for: [expectation], timeout: 10)
//
//        print("Signout Complete")
//
//    }
    
}
