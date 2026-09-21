//
//  TestTimeoutTests.swift
//  Courier_iOS
//

import XCTest
@testable import Courier_iOS

// Tests for the test helpers themselves. `Utils.withTimeout` is what stops a wait that only
// resumes on success from hanging CI forever, so it needs to be known-working rather than assumed
// -- an unverified safety net is worth nothing, and reads as though it is doing something.
final class TestTimeoutTests: XCTestCase {

    func testThrowsWhenTheOperationNeverFinishes() async {

        do {
            try await Utils.withTimeout(seconds: 1, description: "something that never arrives") {
                try await Task.sleep(nanoseconds: 60_000_000_000)
            }
            XCTFail("Expected withTimeout to throw")
        } catch let error as TestFailure {
            guard case .timedOut = error else {
                return XCTFail("Expected .timedOut, got \(error)")
            }
        } catch {
            XCTFail("Expected TestFailure.timedOut, got \(error)")
        }

    }

    func testReturnsTheValueWhenTheOperationFinishesInTime() async throws {

        let value = try await Utils.withTimeout(seconds: 5, description: "an immediate value") {
            42
        }

        XCTAssertEqual(value, 42)

    }

    func testPropagatesTheOperationsOwnError() async {

        struct Boom: Error {}

        do {
            try await Utils.withTimeout(seconds: 5, description: "an operation that throws") {
                throw Boom()
            }
            XCTFail("Expected the operation's error to propagate")
        } catch is Boom {
            // Expected: a real failure must surface as itself, not as a timeout.
        } catch {
            XCTFail("Expected Boom, got \(error)")
        }

    }

}
