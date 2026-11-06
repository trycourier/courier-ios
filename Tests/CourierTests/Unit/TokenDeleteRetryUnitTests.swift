//
//  TokenDeleteRetryUnitTests.swift
//  Courier_iOS
//

import Foundation
import XCTest
@testable import Courier_iOS

// A push token delete that fails at sign-out is kept and retried on the next launch or sign-in,
// so a signed-out device stops receiving the previous user's pushes.
class TokenDeleteRetryUnitTests: XCTestCase {

    // Holds a send open until the test releases it
    private actor Gate {
        private var waiters: [CheckedContinuation<Void, Never>] = []
        private var isOpen = false

        var waiting: Int { waiters.count }

        func wait() async {
            if isOpen { return }
            await withCheckedContinuation { waiters.append($0) }
        }

        func open() {
            isOpen = true
            waiters.forEach { $0.resume() }
            waiters = []
        }
    }

    private actor Sent {
        private(set) var tokens: [String] = []
        func add(_ token: String) { tokens.append(token) }
    }

    private var originalStore: SecretStore?
    private var originalSend: (@CourierActor (PendingTokenDelete) async throws -> Void)?

    private func delete(_ token: String, user: String = "user", age: TimeInterval = 0) -> PendingTokenDelete {
        return PendingTokenDelete(
            userId: user,
            token: token,
            jwt: "jwt-\(user)",
            restUrl: "https://api.example.com",
            createdAt: Date().addingTimeInterval(-age)
        )
    }

    @CourierActor
    private func setUpModule() -> (SecretStore, @CourierActor (PendingTokenDelete) async throws -> Void) {
        let store = UserManager.shared.secrets
        let send = Courier.shared.tokenModule.sendPendingDelete
        UserManager.shared.secrets = MemorySecretStore()
        return (store, send)
    }

    @CourierActor
    private func setSend(_ send: @escaping @CourierActor (PendingTokenDelete) async throws -> Void) {
        Courier.shared.tokenModule.sendPendingDelete = send
    }

    @CourierActor
    private func setPending(_ deletes: [PendingTokenDelete]) {
        Courier.shared.tokenModule.pendingDeletes = deletes
    }

    @CourierActor
    private func pending() -> [PendingTokenDelete] {
        return Courier.shared.tokenModule.pendingDeletes
    }

    override func setUp() async throws {
        try await super.setUp()
        (originalStore, originalSend) = await setUpModule()
    }

    override func tearDown() async throws {
        await setPending([])
        await Courier.shared.tokenModule.dispose()
        await Courier.shared.signOutForTests()
        if let originalSend { await setSend(originalSend) }
        if let originalStore { await Courier.shared.restoreSecrets(originalStore) }
        try await super.tearDown()
    }

    // MARK: Remembering

    func testOfflineSignOutRemembersTheDelete() async throws {
        await UserManager.shared.setCredentials(
            userId: "user",
            accessToken: "jwt-user",
            clientKey: nil,
            tenantId: nil,
            apiUrls: CourierClient.ApiUrls(),
            showLogs: false
        )
        // Nothing listens on this port, so the delete fails the way it does offline
        let unreachable = CourierClient.ApiUrls(rest: "https://127.0.0.1:9")
        await Courier.shared.setClientForTests(CourierClient(jwt: "jwt-user", userId: "user", apiUrls: unreachable, showLogs: false))
        await Courier.shared.tokenModule.cacheToken(key: "apn", value: "token-a")

        await Courier.shared.deletePushTokens()

        let deletes = await pending()
        XCTAssertEqual(deletes.map(\.token), ["token-a"])
        XCTAssertEqual(deletes.first?.userId, "user")
        XCTAssertEqual(deletes.first?.jwt, "jwt-user")
        XCTAssertEqual(deletes.first?.restUrl, "https://127.0.0.1:9")
    }

    func testOnlyRetryableFailuresAreRemembered() async {
        let client = CourierClient(jwt: "jwt-user", userId: "user", showLogs: false)
        let module = await Courier.shared.tokenModule

        await module.rememberFailedDelete("rejected", client: client, error: CourierError(code: 401, message: "Unauthorized"))
        await module.rememberFailedDelete("gone", client: client, error: CourierError(code: 404, message: "Not found"))
        await module.rememberFailedDelete("offline", client: client, error: URLError(.notConnectedToInternet))
        await module.rememberFailedDelete("busy", client: client, error: CourierError(code: 503, message: "Unavailable"))
        await module.rememberFailedDelete("limited", client: client, error: CourierError(code: 429, message: "Too many"))

        let deletes = await pending()
        XCTAssertEqual(deletes.map(\.token), ["offline", "busy", "limited"])
    }

    func testDeleteWithoutAJwtIsNotRemembered() async {
        let client = CourierClient(clientKey: "client-key", userId: "user", showLogs: false)
        await Courier.shared.tokenModule.rememberFailedDelete("token", client: client, error: URLError(.timedOut))
        let deletes = await pending()
        XCTAssertTrue(deletes.isEmpty)
    }

    func testPendingDeletesStayOutOfUserDefaults() async throws {
        let store = MemorySecretStore()
        await Courier.shared.restoreSecrets(store)
        await setPending([delete("token")])

        XCTAssertNotNil(store.stored("courier_pending_token_deletes"))
        let defaults = UserDefaults.standard.dictionaryRepresentation()
        XCTAssertFalse(defaults.values.contains { "\($0)".contains("jwt-user") })
    }

    // MARK: Retrying

    func testRetryDropsSentAndRejectedDeletesAndKeepsOfflineOnes() async {
        await setPending([delete("sent"), delete("offline"), delete("rejected")])
        await setSend { delete in
            switch delete.token {
            case "offline": throw URLError(.notConnectedToInternet)
            case "rejected": throw CourierError(code: 401, message: "Unauthorized")
            default: return
            }
        }

        await Courier.shared.tokenModule.retryPendingDeletes()

        let deletes = await pending()
        XCTAssertEqual(deletes.map(\.token), ["offline"])
    }

    func testExpiredDeletesAreDroppedWithoutSending() async {
        let sent = Sent()
        await setPending([delete("old", age: PendingTokenDelete.maxAge + 60), delete("new")])
        await setSend { await sent.add($0.token) }

        await Courier.shared.tokenModule.retryPendingDeletes()

        let tokens = await sent.tokens
        let deletes = await pending()
        XCTAssertEqual(tokens, ["new"])
        XCTAssertTrue(deletes.isEmpty)
    }

    func testConcurrentRetriesShareOnePass() async {
        let gate = Gate()
        let sent = Sent()
        await setPending([delete("token")])
        await setSend { delete in
            await gate.wait()
            await sent.add(delete.token)
        }

        let module = await Courier.shared.tokenModule
        let first = Task { await module.retryPendingDeletes() }
        for _ in 0..<200 where await gate.waiting == 0 {
            try? await Task.sleep(nanoseconds: 5_000_000)
        }
        let second = Task { await module.retryPendingDeletes() }
        try? await Task.sleep(nanoseconds: 50_000_000)
        await gate.open()
        await first.value
        await second.value

        let tokens = await sent.tokens
        XCTAssertEqual(tokens, ["token"])
    }

    func testDeleteRememberedDuringARetryIsKept() async {
        let gate = Gate()
        await setPending([delete("first")])
        await setSend { _ in await gate.wait() }

        let module = await Courier.shared.tokenModule
        let retry = Task { await module.retryPendingDeletes() }
        for _ in 0..<200 where await gate.waiting == 0 {
            try? await Task.sleep(nanoseconds: 5_000_000)
        }
        let client = CourierClient(jwt: "jwt-user", userId: "user", showLogs: false)
        await module.rememberFailedDelete("second", client: client, error: URLError(.timedOut))
        await gate.open()
        await retry.value

        let deletes = await pending()
        XCTAssertEqual(deletes.map(\.token), ["second"])
    }

    // MARK: Signing in

    // The server moves a token to whoever registers it, so a late delete for the previous user
    // must not run after the next sign-in registers the same token
    func testRegisteringATokenForgetsItsPendingDelete() async {
        await setPending([delete("this-device", user: "previous"), delete("other-device", user: "previous")])
        await Courier.shared.tokenModule.forgetPendingDeletes(for: ["this-device"])

        let deletes = await pending()
        XCTAssertEqual(deletes.map(\.token), ["other-device"])
    }

}

@CourierActor
private extension Courier {

    func setClientForTests(_ client: CourierClient?) {
        self.client = client
    }

    func signOutForTests() {
        self.client = nil
        UserManager.shared.removeCredentials()
    }

    func restoreSecrets(_ store: SecretStore) {
        UserManager.shared.secrets = store
    }

}
