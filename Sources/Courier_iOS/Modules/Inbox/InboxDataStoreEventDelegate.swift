//
//  InboxDataStoreEventDelegate.swift
//  Courier_iOS
//
//  Created by Michael Miller on 2/14/25.
//

public enum InboxMessageEvent: String, Codable {
    case added = "added"
    case read = "read"
    case unread = "unread"
    case opened = "opened"
    case archived = "archived"
    case clicked = "clicked"
}

internal protocol InboxDataStoreEventDelegate {
    @CourierActor func onLoading(_ isRefresh: Bool) async
    @CourierActor func onError(_ error: Error) async
    @CourierActor func onMessagesChanged(_ messages: [InboxMessage], _ canPaginate: Bool, for feed: InboxMessageFeed) async
    @CourierActor func onPageAdded(_ messages: [InboxMessage], _ canPaginate: Bool, isFirstPage: Bool, for feed: InboxMessageFeed) async
    @CourierActor func onMessageEvent(_ message: InboxMessage, at index: Int, to feed: InboxMessageFeed, event: InboxMessageEvent) async
    @CourierActor func onTotalCountUpdated(totalCount: Int, to feed: InboxMessageFeed) async
    @CourierActor func onUnreadCountUpdated(unreadCount: Int) async
}
