//
//  MemorySecretStore.swift
//  Courier_iOS
//

import Foundation
@testable import Courier_iOS

// The Keychain isn't available to the test bundle, so tests swap this in and force every outcome
final class MemorySecretStore: SecretStore, @unchecked Sendable {
    private let lock = NSLock()
    private var values: [String: String] = [:]
    var isAvailable = true
    var isWritable = true

    func read(_ account: String) -> SecretRead {
        lock.lock(); defer { lock.unlock() }
        guard isAvailable else { return .unavailable }
        return values[account].map { .found($0) } ?? .missing
    }

    func write(_ value: String, for account: String) -> Bool {
        lock.lock(); defer { lock.unlock() }
        guard isWritable else { return false }
        values[account] = value
        return true
    }

    func delete(_ account: String) {
        lock.lock(); defer { lock.unlock() }
        values[account] = nil
    }

    func stored(_ account: String) -> String? {
        lock.lock(); defer { lock.unlock() }
        return values[account]
    }
}
