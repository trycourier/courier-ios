import XCTest
@testable import Courier

final class CourierTests: XCTestCase {
    
//    @available(iOS 10.0.0, *)
//    func testQueue() throws {
//        
//        let expectation = self.expectation(description: "Test")
//        
//        print("Testing Queue")
//        
//        let taskManager = CourierTaskManager()
//        
//        taskManager.onTasksCompleted = {
//            print("Tasks completed")
//            expectation.fulfill()
//        }
//        
//        for i in 0...5 {
//            
//            let task = CourierTask(
//                onSuccess: {
//                    print("Handler called onSuccess \(i)")
//                },
//                onFailure: {
//                    print("Handler called onFailure \(i)")
//                })
//            
//            taskManager.add(task: task)
//            
//        }
//        
//        wait(for: [expectation], timeout: 10)
//        
//        print("Queue Tested")
//        
//    }
    
    @available(iOS 10.0.0, *)
    func testLaunch() throws {

        print("Starting SDK")

        let expectation = self.expectation(description: "Updating User")

        Courier.shared.taskManager.onTasksCompleted = {
            print("Tasks completed")
            expectation.fulfill()
        }

        Courier.shared.authorizationKey = "pk_prod_3EH7GNYRC9409PMQGRQE37GC6ABP"
        Courier.shared.user = CourierUser(id: "example_user")

        wait(for: [expectation], timeout: 10)

        print("SDK Started")

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
