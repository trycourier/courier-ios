//
//  InboxDataStore.swift
//  Courier_iOS
//
//  Created by Michael Miller on 2/14/25.
//

@CourierActor
internal class InboxDataStore {
    
    var delegate: InboxDataStoreEventDelegate? = nil
    
    internal(set) public var feed: InboxMessageDataSet = InboxMessageDataSet()
    internal(set) public var archive: InboxMessageDataSet = InboxMessageDataSet()
    internal(set) public var unreadCount: Int = 0

    /// Adds a message to either `feed` or `archived`
    /// - Parameters:
    ///   - message: The message to be added
    ///   - index: The position in the array (if out of bounds, appends)
    ///   - feedType: Determines whether to add to `feed` or `archived`
    internal func addMessage(_ message: InboxMessage, at index: Int, to feedType: InboxMessageFeed) async {
        switch feedType {
        case .feed:
            
            // Add message to feed
            if index >= 0, index <= feed.messages.count {
                feed.messages.insert(message, at: index)
                await delegate?.onMessageAdded(message, at: index, to: feedType)
            } else {
                feed.messages.append(message)
                await delegate?.onMessageAdded(message, at: 0, to: feedType)
            }
            
            // Update Count
            feed.totalCount += 1
            await delegate?.onTotalCountUpdated(totalCount: feed.totalCount, to: feedType)
            
            // Update unread count
            if !message.isRead {
                unreadCount += 1
                await delegate?.onUnreadCountUpdated(unreadCount: unreadCount)
            }
            
        case .archived:
            
            // Add message to archive
            if index >= 0, index <= archive.messages.count {
                archive.messages.insert(message, at: index)
                await delegate?.onMessageAdded(message, at: index, to: feedType)
            } else {
                archive.messages.append(message)
                await delegate?.onMessageAdded(message, at: index, to: feedType)
            }
            
            // Update Count
            archive.totalCount += 1
            await delegate?.onTotalCountUpdated(totalCount: archive.totalCount, to: feedType)
            
        }
    }

    /// Archives a message at a specific index in the specified dataset
    /// - Returns: `true` if successful, `false` if index is invalid
    @discardableResult
    internal func archiveMessage(at index: Int, from feedType: InboxMessageFeed) async -> Bool {
        switch feedType {
        case .feed:
            
            guard index >= 0, index < feed.messages.count else { return false }
            
            // Update the unread count
            if !feed.messages[index].isRead {
                unreadCount -= 1
                await delegate?.onUnreadCountUpdated(unreadCount: unreadCount)
            }
            
            // Remove message
            let message = feed.messages[index]
            feed.messages.remove(at: index)
            await delegate?.onMessageRemoved(message, at: index, to: feedType)
            
            feed.totalCount -= 1
            await delegate?.onTotalCountUpdated(totalCount: feed.totalCount, to: feedType)
            
            return true
            
        case .archived:
            return false
        }
    }
    
    /// Removes and resets everything
    internal func dispose() async {
        self.feed = InboxMessageDataSet()
        self.archive = InboxMessageDataSet()
        self.unreadCount = 0
        await delegate?.onDispose()
    }
    
//
//    /// Updates unread count
//    internal func updateUnreadCount(_ count: Int) {
//        self.unreadCount = count
//    }
//
//    /// Moves a message from `feed` to `archived`
//    /// - Returns: `true` if successful, `false` if the message was not found
//    @discardableResult
//    internal func archiveMessage(at index: Int) -> Bool {
//        guard index >= 0, index < feed.messages.count else { return false }
//        let message = feed.messages.remove(at: index)
//        feed.totalCount -= 1
//        archived.messages.append(message)
//        archived.totalCount += 1
//        return true
//    }
}
