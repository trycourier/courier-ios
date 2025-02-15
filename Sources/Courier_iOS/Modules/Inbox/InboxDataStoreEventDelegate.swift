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
    @CourierActor func onDataSetUpdated(_ data: InboxMessageDataSet, for feed: InboxMessageFeed) async
    @CourierActor func onMessageEvent(_ message: InboxMessage, at index: Int, to feed: InboxMessageFeed, event: InboxMessageEvent) async
    @CourierActor func onTotalCountUpdated(totalCount: Int, to feed: InboxMessageFeed) async
    @CourierActor func onUnreadCountUpdated(unreadCount: Int) async
    @CourierActor func onDispose() async
}
