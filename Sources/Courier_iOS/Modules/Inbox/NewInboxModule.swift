//
//  NewInboxModule.swift
//  Courier_iOS
//
//  Created by Michael Miller on 2/14/25.
//

@CourierActor
internal class NewInboxModule: InboxDataStoreEventDelegate {
    
    let courier: Courier
    let dataStore: InboxDataStore = InboxDataStore()
    
    init(courier: Courier) {
        self.courier = courier
        self.dataStore.delegate = self
    }
    
    // MARK: Listeners
    
    var inboxListeners: [NewCourierInboxListener] = []
    
    func addListener(_ listener: NewCourierInboxListener) {
        self.inboxListeners.append(listener)
        self.courier.client?.log("Courier Inbox Listener Registered. Total Listeners: \(self.inboxListeners.count)")
    }
    
    func removeListener(_ listener: NewCourierInboxListener) {
        self.inboxListeners.removeAll(where: { return $0 == listener })
        self.courier.client?.log("Courier Inbox Listener Unregistered. Total Listeners: \(self.inboxListeners.count)")
    }
    
    func removeAllListeners() {
        self.inboxListeners.removeAll()
        self.courier.client?.log("Courier Inbox Listeners Removed. Total Listeners: \(self.inboxListeners.count)")
    }
    
    func dispose() async {
        await self.dataStore.dispose()
        self.removeAllListeners()
    }
    
    // MARK: DataStore Events
    
    func onMessagesChanged(_ messages: [InboxMessage], _ canPaginate: Bool, for feed: InboxMessageFeed) async {
        let listeners = self.inboxListeners
        await MainActor.run {
            listeners.forEach { listener in
                listener.onMessagesChanged?(messages, canPaginate, feed)
            }
        }
    }
    
    func onMessageEvent(_ message: InboxMessage, at index: Int, to feed: InboxMessageFeed, event: InboxMessageEvent) async {
        let listeners = self.inboxListeners
        await MainActor.run {
            listeners.forEach { listener in
                listener.onMessageEvent?(message, index, feed, event)
            }
        }
    }
    
    func onTotalCountUpdated(totalCount: Int, to feed: InboxMessageFeed) async {
        let listeners = self.inboxListeners
        await MainActor.run {
            listeners.forEach { listener in
                listener.onTotalCountChanged?(totalCount, feed)
            }
        }
    }
    
    func onUnreadCountUpdated(unreadCount: Int) async {
        let listeners = self.inboxListeners
        await MainActor.run {
            listeners.forEach { listener in
                listener.onUnreadCountChanged?(unreadCount)
            }
        }
    }
    
}
