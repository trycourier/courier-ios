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
    
    var inboxListeners: [CourierInboxListener] = []
    
    func addListener(_ listener: CourierInboxListener) {
        self.inboxListeners.append(listener)
        self.courier.client?.log("Courier Inbox Listener Registered. Total Listeners: \(self.inboxListeners.count)")
    }
    
    func removeListener(_ listener: CourierInboxListener) {
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
    
    // MARK: Inbox DataStore Events
    
    func onMessageAdded(_ message: InboxMessage, at index: Int, to feed: InboxMessageFeed) async {
        let listeners = self.inboxListeners
        await MainActor.run {
            listeners.forEach { listener in
                listener.onMessageAdded?(feed, index, message)
            }
        }
    }
    
    func onMessageRemoved(_ message: InboxMessage, at index: Int, to feed: InboxMessageFeed) async {
        let listeners = self.inboxListeners
        await MainActor.run {
            listeners.forEach { listener in
                listener.onMessageRemoved?(feed, index, message)
            }
        }
    }
    
    func onTotalCountUpdated(totalCount: Int, to feed: InboxMessageFeed) async {
        // TODO: Finish
    }
    
    func onUnreadCountUpdated(unreadCount: Int) async {
        let listeners = self.inboxListeners
        await MainActor.run {
            listeners.forEach { listener in
                listener.onUnreadCountChanged?(unreadCount)
            }
        }
    }
    
    func onDispose() async {
        // TODO: Finish
    }
    
}
