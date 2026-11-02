//
//  CourierActorTests.swift
//  Courier_iOS
//

import XCTest
@testable import Courier_iOS

// @CourierActor exists to run Courier's work in isolation from the host app, on its own serial
// queue rather than the shared cooperative pool.
//
// That isolation is easy to lose silently: the executor has to be its own type *and* the actor has
// to override `unownedExecutor`. An earlier version implemented `asUnownedSerialExecutor()` alone,
// which satisfies the SerialExecutor conformance without redirecting anything, and quietly ran on
// the cooperative pool for months. Nothing failed, because an actor's default executor is serial
// too -- the isolation was gone but the correctness was not.
//
// So these assert the queue, not just the serialization. Losing the dedicated queue is exactly the
// regression that goes unnoticed otherwise.

private func currentQueueLabel() -> String {
    String(cString: __dispatch_queue_get_label(nil))
}

@CourierActor
private func queueLabelOnCourierActor() -> String {
    currentQueueLabel()
}

@CourierActor
private final class Counter {

    private var count = 0
    private var inFlight = 0
    private var maxInFlight = 0

    func bump() {
        inFlight += 1
        maxInFlight = max(maxInFlight, inFlight)
        // Deliberately a read-modify-write: without serialization this loses updates.
        let snapshot = count
        count = snapshot + 1
        inFlight -= 1
    }

    func result() -> (count: Int, maxInFlight: Int) {
        (count, maxInFlight)
    }

}

final class CourierActorTests: XCTestCase {

    func testRunsOnCourierSerialQueue() async {

        let label = await queueLabelOnCourierActor()

        XCTAssertEqual(
            label,
            CourierSerialExecutor.queueLabel,
            "@CourierActor is running on \(label) instead of its own queue — the custom executor "
                + "is not wired up, so SDK work is sharing the host app's cooperative pool"
        )

    }

    func testDoesNotRunOnTheMainThread() async {

        let label = await queueLabelOnCourierActor()

        XCTAssertNotEqual(label, "com.apple.main-thread", "@CourierActor must not run on the main queue")

    }

    func testSerializesConcurrentWork() async {

        let counter = Counter()

        await withTaskGroup(of: Void.self) { group in
            for _ in 0..<200 {
                group.addTask { await counter.bump() }
            }
        }

        let (count, maxInFlight) = await counter.result()

        XCTAssertEqual(count, 200, "Lost updates — @CourierActor did not serialize")
        XCTAssertEqual(maxInFlight, 1, "Overlapping execution — @CourierActor did not serialize")

    }

}
