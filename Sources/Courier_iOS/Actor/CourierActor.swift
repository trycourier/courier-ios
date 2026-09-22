//
//  CourierActor.swift
//  Courier_iOS
//
//  Created by Michael Miller on 2/12/25.
//

import Foundation

// Handles executing all Courier logic on a specific Actor
// This prevents threading issues from happening when calling
// Many different parts of the kit at the same time
@globalActor public struct CourierActor {
    public static let shared = CourierExecutor()
}

// Courier's work runs on its own serial queue, not the cooperative thread pool, so that it is
// isolated from whatever the host app is doing. On the shared pool our work competes for the same
// handful of threads as every other async task in the app, and a busy app pushes SDK work behind
// its own.
//
// Getting that isolation takes two things, and missing either silently gives you the shared pool
// instead:
//
//   1. The executor must be its own type. An actor cannot serve as its own executor.
//   2. The actor must override `unownedExecutor`. Global-actor isolation routes through
//      `shared.unownedExecutor`, so implementing `asUnownedSerialExecutor()` alone satisfies the
//      SerialExecutor conformance without redirecting anything.
//
// An earlier version did (2) without (1) and ran on the cooperative pool for months without
// anyone noticing. CourierActorTests asserts the queue so that cannot happen again.
public actor CourierExecutor {

    private nonisolated let executor = CourierSerialExecutor()

    public nonisolated var unownedExecutor: UnownedSerialExecutor {
        executor.asUnownedSerialExecutor()
    }

}

public final class CourierSerialExecutor: SerialExecutor {

    static let queueLabel = "com.courier.swift"

    private let queue = DispatchQueue(label: CourierSerialExecutor.queueLabel)

    nonisolated public func enqueue(_ job: UnownedJob) {
        queue.async {
            job.runSynchronously(on: self.asUnownedSerialExecutor())
        }
    }

    nonisolated public func asUnownedSerialExecutor() -> UnownedSerialExecutor {
        UnownedSerialExecutor(ordinary: self)
    }

}
