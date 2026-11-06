//
//  SecretStore.swift
//  Courier_iOS
//

import Foundation
import Security

internal enum SecretRead: Equatable {
    case found(String)
    case missing
    // Locked before the first unlock since boot, or no Keychain access at all. Not the same as
    // missing: nothing should be cleared because of it.
    case unavailable
}

internal protocol SecretStore: Sendable {
    func read(_ account: String) -> SecretRead
    @discardableResult func write(_ value: String, for account: String) -> Bool
    func delete(_ account: String)
}

// The access token and client key live in the Keychain, never in backups or device transfers.
// "After first unlock" matches the UserDefaults plist, so both become readable at the same time.
internal struct KeychainSecretStore: SecretStore {

    private let service = "com.courier.ios.credentials"

    private func query(_ account: String) -> [String: Any] {
        return [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
    }

    func read(_ account: String) -> SecretRead {
        var request = query(account)
        request[kSecReturnData as String] = true
        request[kSecMatchLimit as String] = kSecMatchLimitOne

        var item: CFTypeRef?
        switch SecItemCopyMatching(request as CFDictionary, &item) {
        case errSecSuccess:
            guard let data = item as? Data, let value = String(data: data, encoding: .utf8) else {
                return .missing
            }
            return .found(value)
        case errSecItemNotFound:
            return .missing
        default:
            return .unavailable
        }
    }

    func write(_ value: String, for account: String) -> Bool {
        delete(account)
        var item = query(account)
        item[kSecValueData as String] = Data(value.utf8)
        item[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        return SecItemAdd(item as CFDictionary, nil) == errSecSuccess
    }

    func delete(_ account: String) {
        SecItemDelete(query(account) as CFDictionary)
    }

}
