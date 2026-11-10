//
//  RequestHardeningUnitTests.swift
//  Courier_iOS
//

import Foundation
import XCTest
@testable import Courier_iOS

// Ids go into GraphQL documents and REST paths, credentials go into headers that get logged, and
// tracking URLs come from push payloads. None of them should be able to change the request.
class RequestHardeningUnitTests: XCTestCase {

    // MARK: GraphQL

    func testGraphQLStringEscapesQuotesAndBackslashes() {
        XCTAssertEqual("plain-id".graphQLString, "\"plain-id\"")
        XCTAssertEqual("a\"b".graphQLString, "\"a\\\"b\"")
        XCTAssertEqual("a\\b".graphQLString, "\"a\\\\b\"")
        XCTAssertEqual("a\nb".graphQLString, "\"a\\nb\"")
        XCTAssertEqual("YWJj/ZGVm+==".graphQLString, "\"YWJj/ZGVm+==\"")
    }

    func testGraphQLStringCantCloseTheArgument() throws {
        let hostile = "x\") { id } other: archive(messageId: \"y"
        let literal = hostile.graphQLString

        // Decoding the literal gives back exactly the input, so it stayed one string
        let decoded = try JSONDecoder().decode(String.self, from: Data(literal.utf8))
        XCTAssertEqual(decoded, hostile)
    }

    // MARK: REST paths

    func testPathSegmentEncodesSeparators() {
        XCTAssertEqual("user-1".urlPathSegment, "user-1")
        XCTAssertEqual("a/b".urlPathSegment, "a%2Fb")
        XCTAssertEqual("a?b".urlPathSegment, "a%3Fb")
        XCTAssertEqual("a#b".urlPathSegment, "a%23b")
        XCTAssertEqual("a b".urlPathSegment, "a%20b")
        XCTAssertEqual("../tokens".urlPathSegment, "..%2Ftokens")
    }

    // The API keeps `%2B`, `%40` and `%3A` encoded in a path, so encoding them changes the user or token
    func testPathSegmentKeepsPlusAtAndColon() {
        XCTAssertEqual("a+b@example.com".urlPathSegment, "a+b@example.com")
        XCTAssertEqual("fcm-1:APA91b_x-y".urlPathSegment, "fcm-1:APA91b_x-y")
    }

    func testQueryValueEncodesSeparators() {
        XCTAssertEqual("cursor".urlQueryValue, "cursor")
        XCTAssertEqual("a&b=c".urlQueryValue, "a%26b%3Dc")
        XCTAssertEqual("a+b".urlQueryValue, "a%2Bb")
        XCTAssertEqual("a#b".urlQueryValue, "a%23b")
    }

    func testUserIdStaysOnePathSegment() throws {
        let path = "https://api.example.com/users/\("../admin".urlPathSegment)/tokens"
        let url = try XCTUnwrap(URL(string: path))

        // The encoded path is what goes on the wire. pathComponents decodes before splitting on older iOS.
        XCTAssertEqual(URLComponents(url: url, resolvingAgainstBaseURL: false)?.percentEncodedPath, "/users/..%2Fadmin/tokens")
        XCTAssertEqual(url.standardized.absoluteString, path)
    }

    // MARK: Logs

    func testCredentialHeadersAreRedacted() {
        let redacted = CourierClient.Options.redactingCredentials([
            "Authorization": "Bearer secret",
            "x-courier-client-key": "secret",
            "X-Courier-Client-Key": "secret",
            "Content-Type": "application/json",
            "x-courier-user-id": "user"
        ])

        XCTAssertEqual(redacted["Authorization"], "<redacted>")
        XCTAssertEqual(redacted["x-courier-client-key"], "<redacted>")
        XCTAssertEqual(redacted["X-Courier-Client-Key"], "<redacted>")
        XCTAssertEqual(redacted["Content-Type"], "application/json")
        XCTAssertEqual(redacted["x-courier-user-id"], "user")
    }

    // MARK: Tracking

    func testTrackingRejectsUrlsThatArentHttps() async {
        let client = CourierClient(jwt: nil, userId: "user", showLogs: false)

        for url in ["http://example.com/t/abc", "file:///etc/hosts", "not a url", ""] {
            do {
                try await client.tracking.postTrackingUrl(url: url, event: .delivered)
                XCTFail("Posted to \(url)")
            } catch let error as CourierError {
                XCTAssertEqual(error.message, "Tracking URL must use https")
            } catch {
                XCTFail("Unexpected error for \(url): \(error)")
            }
        }
    }

    func testTrackingTimeoutIsShort() {
        XCTAssertLessThanOrEqual(TrackingClient.timeout, 10)
    }

}
