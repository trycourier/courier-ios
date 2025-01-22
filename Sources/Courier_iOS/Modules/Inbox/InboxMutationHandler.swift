//
//  InboxMutationHandler.swift
//  Courier_iOS
//
//  Created by https://github.com/mikemilla on 1/22/25.
//

internal protocol InboxMutationHandler {
    func onInboxReload(isRefresh: Bool) async
    func onInboxKilled() async
    func onInboxReset(inbox: CourierInboxData, error: Error) async
    func onInboxUpdated(inbox: CourierInboxData) async
    func onInboxItemAdded(at index: Int, in feed: InboxMessageFeed, with message: InboxMessage) async
    func onInboxItemRemove(at index: Int, in feed: InboxMessageFeed, with message: InboxMessage) async
    func onInboxItemUpdated(at index: Int, in feed: InboxMessageFeed, with message: InboxMessage) async
    func onInboxPageFetched(feed: InboxMessageFeed, messageSet: InboxMessageSet) async
    func onInboxMessageReceived(message: InboxMessage) async
    func onInboxEventReceived(event: InboxSocket.MessageEvent) async
    func onInboxError(with error: Error) async
    func onUnreadCountChange(count: Int) async
}
