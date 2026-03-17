import XCTest
@testable import Courier_iOS

final class ApiUrlsUnitTests: XCTestCase {
    
    func testDefaultApiUrlsUseCurrentInboxHosts() {
        let urls = CourierClient.ApiUrls()
        
        XCTAssertEqual(urls.rest, "https://api.courier.com")
        XCTAssertEqual(urls.graphql, "https://api.courier.com/client/q")
        XCTAssertEqual(urls.inboxGraphql, "https://inbox.courier.io/q")
        XCTAssertEqual(urls.inboxWebSocket, "wss://realtime.courier.io")
    }
    
    func testEuApiUrlsPreset() {
        let urls = CourierClient.ApiUrls.eu
        
        XCTAssertEqual(urls.rest, "https://api.eu.courier.com")
        XCTAssertEqual(urls.graphql, "https://api.eu.courier.com/client/q")
        XCTAssertEqual(urls.inboxGraphql, "https://inbox.eu.courier.io/q")
        XCTAssertEqual(urls.inboxWebSocket, "wss://realtime.eu.courier.io")
    }
}
