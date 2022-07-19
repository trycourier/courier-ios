import XCTest
@testable import Courier

@available(iOS 10.0.0, *)
final class CourierTests: XCTestCase {
    
    func testA() throws {

        print("🔬 Testing SDK init")
        
        Courier.shared.authorizationKey = "pk_prod_3EH7GNYRC9409PMQGRQE37GC6ABP"

    }
    
    func testB() throws {

        print("🔬 Testing Setting User")

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
            id: "example_id",
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

        wait(for: [expectation], timeout: 10)

    }
    
    func testC() throws {

        print("🔬 Testing Token Update")

        let expectation = self.expectation(description: "Updating User APNS Token")
        
        Courier.shared.taskManager.allTasksCompleted = {
            expectation.fulfill()
        }
        
        // This is just a random UUID for a token
        // This is only here to ensure the updating requests work as expected
        Courier.shared.apnsToken = UUID().uuidString

        wait(for: [expectation], timeout: 10)

    }
    
    func testD() throws {

        print("🔬 Testing Sign Out")

        let expectation = self.expectation(description: "Signing Out User")

        Courier.shared.signOut {
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 10)

    }
    
}
