//
//  InboxSessionUnitTests.swift
//  Courier_iOS
//

import Foundation
import XCTest
@testable import Courier_iOS

// An inbox request that's still in flight when the user signs out, or another user signs in,
// must not post its results. These hold a request open across that change, then let it finish.
class InboxSessionUnitTests: XCTestCase {

    // Holds a request open until the test releases it
    private actor Gate {
        private var waiter: CheckedContinuation<Void, Never>?
        private var isOpen = false

        var hasWaiter: Bool { waiter != nil }

        func wait() async {
            if isOpen { return }
            await withCheckedContinuation { waiter = $0 }
        }

        func open() {
            isOpen = true
            waiter?.resume()
            waiter = nil
        }
    }

    @CourierActor
    private func setClient(_ client: CourierClient?) {
        Courier.shared.client = client
    }

    private func signIn(_ userId: String) async -> CourierClient {
        _ = await UserManager.shared.setCredentials(
            userId: userId,
            accessToken: "jwt-\(userId)",
            clientKey: nil,
            tenantId: nil,
            apiUrls: CourierClient.ApiUrls(),
            showLogs: false
        )
        let client = CourierClient(jwt: "jwt-\(userId)", userId: userId, showLogs: false)
        await setClient(client)
        return client
    }

    private func waitForRequest(_ gate: Gate) async {
        for _ in 0..<200 where await !gate.hasWaiter {
            try? await Task.sleep(nanoseconds: 5_000_000)
        }
    }

    override func setUp() async throws {
        try await super.setUp()
        await Courier.shared.inboxModule.addListener(CourierInboxListener())
    }

    override func tearDown() async throws {
        await Courier.shared.inboxModule.dispose()
        await setClient(nil)
        await UserManager.shared.removeCredentials()
        try await super.tearDown()
    }

    func testInboxFetchIsDroppedAfterSignOut() async throws {
        _ = await signIn("user-a")
        let module = await Courier.shared.inboxModule
        let gate = Gate()
        await setLoadInbox(module, gate: gate, messages: [InboxMessage.new()])

        let request = Task { await module.getInbox(isRefresh: false) }
        await waitForRequest(gate)

        await setClient(nil)
        await UserManager.shared.removeCredentials()
        await gate.open()
        await request.value

        let feed = await module.dataStore.feed.messages
        XCTAssertTrue(feed.isEmpty, "The signed-out user's inbox came back")
    }

    func testInboxFetchIsDroppedAfterUserSwitch() async throws {
        _ = await signIn("user-a")
        let module = await Courier.shared.inboxModule
        let gate = Gate()
        let userAMessage = InboxMessage.new()
        await setLoadInbox(module, gate: gate, messages: [userAMessage])

        let request = Task { await module.getInbox(isRefresh: false) }
        await waitForRequest(gate)

        _ = await signIn("user-b")
        await gate.open()
        await request.value

        let feed = await module.dataStore.feed.messages
        XCTAssertFalse(feed.contains { $0.messageId == userAMessage.messageId }, "User B was shown user A's inbox")
    }

    func testNextPageIsDroppedAfterSignOut() async throws {
        _ = await signIn("user-a")
        let module = await Courier.shared.inboxModule
        let existing = InboxMessage.new()
        await module.dataStore.updateDataSet(
            InboxMessageSet(messages: [existing], totalCount: 2, canPaginate: true, paginationCursor: "page-2"),
            for: .feed
        )

        let gate = Gate()
        await setLoadNextPage(module, gate: gate, messages: [InboxMessage.new()])

        let request = Task { try await module.getNextPage(feedType: .feed) }
        await waitForRequest(gate)

        await setClient(nil)
        await gate.open()
        let page = try await request.value

        XCTAssertNil(page)
        let feed = await module.dataStore.feed.messages
        XCTAssertEqual(feed.map(\.messageId), [existing.messageId], "A page for the signed-out session was added")
    }

    func testOlderLoadDoesNotOverwriteANewerOne() async throws {
        _ = await signIn("user-a")
        let module = await Courier.shared.inboxModule

        // An older load is still in flight
        let olderGate = Gate()
        let older = InboxMessage.new()
        await setLoadInbox(module, gate: olderGate, messages: [older])
        let olderRequest = Task { await module.getInbox(isRefresh: false) }
        await waitForRequest(olderGate)

        // A newer load for the same user, like a pull to refresh, finishes first
        let newerGate = Gate()
        let newer = InboxMessage.new()
        await setLoadInbox(module, gate: newerGate, messages: [newer])
        await newerGate.open()
        await module.getInbox(isRefresh: true)

        await olderGate.open()
        await olderRequest.value

        let feed = await module.dataStore.feed.messages
        XCTAssertEqual(feed.map(\.messageId), [newer.messageId], "An older load overwrote a newer one")
    }

    // MARK: Seams

    @CourierActor
    private func setLoadInbox(_ module: InboxModule, gate: Gate, messages: [InboxMessage]) {
        module.loadInbox = { _, _, _, _ in
            await gate.wait()
            return (
                feed: InboxMessageSet(messages: messages, totalCount: messages.count),
                archive: InboxMessageSet(),
                unreadCount: messages.count
            )
        }
    }

    @CourierActor
    private func setLoadNextPage(_ module: InboxModule, gate: Gate, messages: [InboxMessage]) {
        module.loadNextPage = { _, _, _, _ in
            await gate.wait()
            return InboxMessageSet(messages: messages, totalCount: messages.count)
        }
    }

}
