//
//  CredentialStorageUnitTests.swift
//  Courier_iOS
//

import Foundation
import XCTest
@testable import Courier_iOS

// The access token and client key live in the Keychain, with UserDefaults as the fallback when the
// Keychain can't be written. These run against an in-memory store so every Keychain outcome can be
// forced, plus one round trip through the real Keychain where the test host allows it.
class CredentialStorageUnitTests: XCTestCase {

    private final class MemorySecretStore: SecretStore, @unchecked Sendable {
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

    private var store = MemorySecretStore()
    private var originalStore: SecretStore?

    private var savedDefaults: [String: String]? {
        UserDefaults.standard.object(forKey: "courier_credentials") as? [String: String]
    }

    @CourierActor
    private func useStore(_ store: SecretStore) -> SecretStore {
        let original = UserManager.shared.secrets
        UserManager.shared.secrets = store
        return original
    }

    private func signIn(clientKey: String? = "client-key") async {
        await UserManager.shared.setCredentials(
            userId: "user",
            accessToken: "token",
            clientKey: clientKey,
            tenantId: nil,
            apiUrls: CourierClient.ApiUrls(),
            showLogs: false
        )
    }

    override func setUp() async throws {
        try await super.setUp()
        store = MemorySecretStore()
        originalStore = await useStore(store)
    }

    override func tearDown() async throws {
        await UserManager.shared.removeCredentials()
        if let originalStore {
            _ = await useStore(originalStore)
        }
        try await super.tearDown()
    }

    func testSecretsAreKeptOutOfUserDefaults() async throws {
        await signIn()

        let defaults = try XCTUnwrap(savedDefaults)
        XCTAssertNil(defaults["courier_access_token"])
        XCTAssertNil(defaults["courier_client_key"])
        XCTAssertEqual(defaults["courier_user_id"], "user")

        XCTAssertEqual(store.stored("courier_access_token"), "token")
        XCTAssertEqual(store.stored("courier_client_key"), "client-key")
        let token = await UserManager.shared.getAccessToken()
        let clientKey = await UserManager.shared.getClientKey()
        XCTAssertEqual(token, "token")
        XCTAssertEqual(clientKey, "client-key")
    }

    func testSigningInWithoutAClientKeyClearsThePreviousOne() async {
        await signIn(clientKey: "client-key")
        await signIn(clientKey: nil)

        XCTAssertNil(store.stored("courier_client_key"))
        let clientKey = await UserManager.shared.getClientKey()
        XCTAssertNil(clientKey)
    }

    func testSignOutDeletesTheSecrets() async {
        await signIn()
        await UserManager.shared.removeCredentials()

        XCTAssertNil(savedDefaults)
        XCTAssertNil(store.stored("courier_access_token"))
        XCTAssertNil(store.stored("courier_client_key"))
    }

    // A session saved by an earlier version has its secrets in UserDefaults
    func testEarlierSessionIsMovedToTheKeychain() async throws {
        UserDefaults.standard.set([
            "courier_user_id": "user",
            "courier_access_token": "token",
            "courier_client_key": "client-key"
        ], forKey: "courier_credentials")

        let token = await UserManager.shared.getAccessToken()
        let clientKey = await UserManager.shared.getClientKey()
        XCTAssertEqual(token, "token")
        XCTAssertEqual(clientKey, "client-key")

        let defaults = try XCTUnwrap(savedDefaults)
        XCTAssertNil(defaults["courier_access_token"])
        XCTAssertNil(defaults["courier_client_key"])
        XCTAssertEqual(defaults["courier_user_id"], "user")
        XCTAssertEqual(store.stored("courier_access_token"), "token")
        XCTAssertEqual(store.stored("courier_client_key"), "client-key")
    }

    func testEarlierSessionStaysUsableWhenTheKeychainCantBeWritten() async throws {
        store.isWritable = false
        UserDefaults.standard.set([
            "courier_user_id": "user",
            "courier_access_token": "token"
        ], forKey: "courier_credentials")

        let token = await UserManager.shared.getAccessToken()
        XCTAssertEqual(token, "token")
        XCTAssertEqual(savedDefaults?["courier_access_token"], "token")
    }

    func testSignInFallsBackToUserDefaultsWhenTheKeychainCantBeWritten() async {
        store.isWritable = false
        await signIn()

        XCTAssertEqual(savedDefaults?["courier_access_token"], "token")
        XCTAssertEqual(savedDefaults?["courier_client_key"], "client-key")
        let token = await UserManager.shared.getAccessToken()
        let clientKey = await UserManager.shared.getClientKey()
        XCTAssertEqual(token, "token")
        XCTAssertEqual(clientKey, "client-key")
    }

    // Restored from a backup to a new device: UserDefaults came along, the Keychain item didn't
    func testSessionWithoutItsTokenIsSignedOut() async {
        await signIn()
        store.delete("courier_access_token")

        let token = await UserManager.shared.getAccessToken()
        let userId = await UserManager.shared.getUserId()
        let restored = await Courier.shared.authenticationModule.restoreClient()
        XCTAssertNil(token)
        XCTAssertNil(userId)
        XCTAssertNil(restored)
    }

    // Locked before the first unlock: nothing can be read yet, but the session is still valid
    func testLockedKeychainLeavesTheSessionInPlace() async {
        await signIn()
        store.isAvailable = false

        let token = await UserManager.shared.getAccessToken()
        XCTAssertNil(token)
        XCTAssertNotNil(savedDefaults)

        store.isAvailable = true
        let unlockedToken = await UserManager.shared.getAccessToken()
        XCTAssertEqual(unlockedToken, "token")
    }

    func testRealKeychainRoundTrip() throws {
        let keychain = KeychainSecretStore()
        let account = "courier_unit_test_\(UUID().uuidString)"
        defer { keychain.delete(account) }

        guard keychain.write("first", for: account) else {
            throw XCTSkip("The Keychain isn't available to this test host")
        }

        XCTAssertEqual(keychain.read(account), .found("first"))
        XCTAssertTrue(keychain.write("second", for: account))
        XCTAssertEqual(keychain.read(account), .found("second"))
        keychain.delete(account)
        XCTAssertEqual(keychain.read(account), .missing)
    }

}
