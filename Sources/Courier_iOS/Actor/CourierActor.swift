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

public actor CourierExecutor { }

extension CourierExecutor: SerialExecutor {

    nonisolated static let queue = DispatchQueue(label: "com.courier.swift")

    nonisolated public func enqueue(_ job: UnownedJob) {
        Self.queue.async {
            job.runSynchronously(on: self.asUnownedSerialExecutor())
        }
    }
    
    nonisolated public func asUnownedSerialExecutor() -> UnownedSerialExecutor {
        UnownedSerialExecutor(ordinary: self)
    }
    
}
