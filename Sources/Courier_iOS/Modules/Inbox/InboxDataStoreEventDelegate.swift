//
//  InboxDataStoreEventDelegate.swift
//  Courier_iOS
//
//  Created by Michael Miller on 2/14/25.
//

internal protocol InboxDataStoreEventDelegate {
    @CourierActor func onMessageAdded(_ message: InboxMessage, at index: Int, to feed: InboxMessageFeed) async
    @CourierActor func onMessageRemoved(_ message: InboxMessage, at index: Int, to feed: InboxMessageFeed) async
    @CourierActor func onTotalCountUpdated(totalCount: Int, to feed: InboxMessageFeed) async
    @CourierActor func onUnreadCountUpdated(unreadCount: Int) async
    @CourierActor func onDispose() async
}
