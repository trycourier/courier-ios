import XCTest
@testable import Courier

final class CourierTests: XCTestCase {
    
    @available(iOS 10.0.0, *)
    func testLaunch() throws {
        
        print("Starting SDK")
        
        let expectation = self.expectation(description: "Updating User")
        
        Courier.shared.queue.whenCompleteAll = {
            expectation.fulfill()
        }
        
        Courier.shared.authorizationKey = "pk_prod_3EH7GNYRC9409PMQGRQE37GC6ABP"
        Courier.shared.user = CourierUser(id: "mike_miller")
        
        wait(for: [expectation], timeout: 10)
        
        print("SDK Started")
        
    }
    
}
