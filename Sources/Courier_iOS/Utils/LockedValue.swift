//
//  LockedValue.swift
//  Courier_iOS
//

import Foundation

/// A lock-guarded box for a value that has to be read and written from any thread
/// without going through an actor.
internal final class LockedValue<Value>: @unchecked Sendable {
    
    private let lock = NSLock()
    private var storage: Value
    
    init(_ value: Value) {
        self.storage = value
    }
    
    var value: Value {
        get {
            lock.lock()
            defer { lock.unlock() }
            return storage
        }
        set {
            lock.lock()
            defer { lock.unlock() }
            storage = newValue
        }
    }
    
}
