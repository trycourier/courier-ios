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
    func addMessage(_ message: InboxMessage, at index: Int, to feedType: InboxMessageFeed) async {
        switch feedType {
        case .feed:
            
            // Add message to feed
            if index >= 0, index <= feed.messages.count {
                feed.messages.insert(message, at: index)
                await delegate?.onMessageEvent(message, at: index, to: feedType, event: .added)
            } else {
                feed.messages.append(message)
                await delegate?.onMessageEvent(message, at: 0, to: feedType, event: .added)
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
                await delegate?.onMessageEvent(message, at: index, to: feedType, event: .added)
            } else {
                archive.messages.append(message)
                await delegate?.onMessageEvent(message, at: index, to: feedType, event: .added)
            }
            
            // Update Count
            archive.totalCount += 1
            await delegate?.onTotalCountUpdated(totalCount: archive.totalCount, to: feedType)
            
        }
    }
    
    /// Reads a message at a specific index in the specified dataset
    /// - Returns: `true` if successful, `false` if index is invalid
    @discardableResult
    func readMessage(_ message: InboxMessage, from feedType: InboxMessageFeed) async -> Bool {
        switch feedType {
        case .feed:
            
            guard let index = feed.messages.firstIndex(where: { $0.messageId == message.messageId }) else {
                return false
            }
            
            let message = feed.messages[index]
            
            // Read the message
            if !message.isRead {
                
                // Toggle read
                message.setRead()
                await delegate?.onMessageEvent(message, at: index, to: feedType, event: .read)
                
                // Update unread count
                unreadCount -= 1
                await delegate?.onUnreadCountUpdated(unreadCount: unreadCount)
                return true
                
            }
            
        case .archived:
            
            guard let index = archive.messages.firstIndex(where: { $0.messageId == message.messageId }) else {
                return false
            }
            
            let message = archive.messages[index]
            
            // Read the message
            if !message.isRead {
                message.setRead()
                await delegate?.onMessageEvent(message, at: index, to: feedType, event: .read)
                return true
            }
            
        }
        
        return false
        
    }
    
    /// Unreads a message at a specific index in the specified dataset
    /// - Returns: `true` if successful, `false` if index is invalid
    @discardableResult
    func unreadMessage(_ message: InboxMessage, from feedType: InboxMessageFeed) async -> Bool {
        switch feedType {
        case .feed:
            
            guard let index = feed.messages.firstIndex(where: { $0.messageId == message.messageId }) else {
                return false
            }
            
            let message = feed.messages[index]
            
            // Read the message
            if message.isRead {
                
                // Toggle read
                message.setUnread()
                await delegate?.onMessageEvent(message, at: index, to: feedType, event: .unread)
                
                // Update unread count
                unreadCount += 1
                await delegate?.onUnreadCountUpdated(unreadCount: unreadCount)
                return true
                
            }
            
        case .archived:
            
            guard let index = feed.messages.firstIndex(where: { $0.messageId == message.messageId }) else {
                return false
            }
            
            let message = archive.messages[index]
            
            // Read the message
            if message.isRead {
                message.setUnread()
                await delegate?.onMessageEvent(message, at: index, to: feedType, event: .unread)
                return true
            }
            
        }
        
        return false
        
    }

    /// Archives a message at a specific index in the specified dataset
    /// - Returns: `true` if successful, `false` if index is invalid
    @discardableResult
    func archiveMessage(_ message: InboxMessage, from feedType: InboxMessageFeed) async -> Bool {
        switch feedType {
        case .feed:
            
            guard let index = feed.messages.firstIndex(where: { $0.messageId == message.messageId }) else {
                return false
            }
            
            // Update the unread count
            if !feed.messages[index].isRead {
                unreadCount -= 1
                await delegate?.onUnreadCountUpdated(unreadCount: unreadCount)
            }
            
            let message = feed.messages[index]
            
            // Remove message from feed
            feed.messages.remove(at: index)
            await delegate?.onMessageEvent(message, at: index, to: feedType, event: .archived)
            
            // Update feed total counts
            feed.totalCount -= 1
            await delegate?.onTotalCountUpdated(totalCount: feed.totalCount, to: .feed)
            
            // Create copy
            let newMessage = message.copy()
            
            // Add the item to the archive
            let insertIndex = findInsertIndex(for: newMessage, in: archive.messages)
            archive.messages.insert(newMessage, at: insertIndex)
            await delegate?.onMessageEvent(newMessage, at: insertIndex, to: .archived, event: .added)
            
            // Update feed total counts
            archive.totalCount += 1
            await delegate?.onTotalCountUpdated(totalCount: archive.totalCount, to: .archived)
            
            return true
            
        case .archived:
            return false
        }
    }
    
    /// Opens a message at a specific index in the specified dataset
    /// - Returns: `true` if successful, `false` if index is invalid
    @discardableResult
    func openMessage(_ message: InboxMessage, from feedType: InboxMessageFeed) async -> Bool {
        switch feedType {
        case .feed:
            
            guard let index = feed.messages.firstIndex(where: { $0.messageId == message.messageId }) else {
                return false
            }
            
            let message = feed.messages[index]
            
            // Read the message
            if !message.isOpened {
                message.setOpened()
                await delegate?.onMessageEvent(message, at: index, to: feedType, event: .opened)
                return true
            }
            
        case .archived:
            
            guard let index = archive.messages.firstIndex(where: { $0.messageId == message.messageId }) else {
                return false
            }
            
            let message = archive.messages[index]
            
            // Read the message
            if !message.isOpened {
                message.setOpened()
                await delegate?.onMessageEvent(message, at: index, to: feedType, event: .opened)
                return true
            }
            
        }
        
        return false
        
    }
    
    /// Insert new messages
    func updateDataSet(_ data: InboxMessageDataSet, for feedType: InboxMessageFeed) async {
        switch feedType {
        case .feed:
            feed = data
            await delegate?.onDataSetUpdated(feed, for: feedType)
            await delegate?.onTotalCountUpdated(totalCount: feed.totalCount, to: feedType)
        case .archived:
            archive = data
            await delegate?.onDataSetUpdated(feed, for: feedType)
            await delegate?.onTotalCountUpdated(totalCount: archive.totalCount, to: feedType)
        }
    }
    
    /// Update unread count
    func updateUnreadCount(_ count: Int) async {
        unreadCount = count
        await delegate?.onUnreadCountUpdated(unreadCount: count)
    }
    
    /// Removes and resets everything
    func dispose() async {
        self.feed = InboxMessageDataSet()
        self.archive = InboxMessageDataSet()
        self.unreadCount = 0
        await delegate?.onDispose()
    }
    
    private func findInsertIndex(for newMessage: InboxMessage, in messages: [InboxMessage]) -> Int {
        
        var allMessages = messages
        
        // Add the new message to the array
        allMessages.append(newMessage)

        // Sort the messages by createdAt (descending order)
        allMessages.sort { $0.timestamp > $1.timestamp }

        // Find the index of the newly inserted message
        if let index = allMessages.firstIndex(where: { $0.messageId == newMessage.messageId }) {
            return max(index - 1, 0)
        }

        // Fallback
        return 0
        
    }
    
}
