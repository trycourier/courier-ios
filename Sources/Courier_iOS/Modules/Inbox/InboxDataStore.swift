//
//  InboxDataStore.swift
//  Courier_iOS
//
//  Created by Michael Miller on 2/14/25.
//

@CourierActor
internal class InboxDataStore {
    
    var delegate: InboxDataStoreEventDelegate? = nil
    
    internal(set) public var feed: InboxMessageSet = InboxMessageSet()
    internal(set) public var archive: InboxMessageSet = InboxMessageSet()
    internal(set) public var unreadCount: Int = 0
    
    /// Creates an  identical copy of the data
    func getSnapshot() -> (feed: InboxMessageSet, archive: InboxMessageSet, unreadCount: Int) {
        return (feed, archive, unreadCount)
    }
    
    /// Reloads the data store from a snapshot
    func reloadSnapshot(_ snapshot: (feed: InboxMessageSet, archive: InboxMessageSet, unreadCount: Int)) async {
        await updateUnreadCount(snapshot.unreadCount)
        await updateDataSet(snapshot.feed, for: .feed)
        await updateDataSet(snapshot.archive, for: .archive)
    }
    
    /// Returns a message by id
    func getMessageIndexById(feedType: InboxMessageFeed, messageId: String) -> Int? {
        
        switch feedType {
        case .feed:
            guard let index = feed.messages.firstIndex(where: { $0.messageId == messageId }) else {
                return nil
            }
            return index
        case .archive:
            guard let index = archive.messages.firstIndex(where: { $0.messageId == messageId }) else {
                return nil
            }
            return index
        }
        
    }
    
    func getMessageById(feedType: InboxMessageFeed, messageId: String) -> InboxMessage? {
        
        guard let index = getMessageIndexById(feedType: feedType, messageId: messageId) else {
            return nil
        }
        
        switch feedType {
        case .feed:
            return feed.messages[index]
        case .archive:
            return archive.messages[index]
        }
        
    }

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
            
            await delegate?.onMessagesChanged(feed.messages, feed.canPaginate, for: feedType)
            
        case .archive:
            
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
            
            await delegate?.onMessagesChanged(archive.messages, archive.canPaginate, for: feedType)
            
        }
    }
    
    /// Reads a message at a specific index in the specified dataset
    /// - Returns: `true` if successful, `false` if index is invalid
    @discardableResult
    func readMessage(_ message: InboxMessage, from feedType: InboxMessageFeed, client: CourierClient?) async -> Bool {
        
        // Create a copy of the state
        let snapshot = getSnapshot()
        
        // Value for handling server updates
        var canUpdate = false
        
        switch feedType {
        case .feed:
            
            guard let index = getMessageIndexById(feedType: feedType, messageId: message.messageId) else {
                return canUpdate
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
                await delegate?.onMessagesChanged(feed.messages, feed.canPaginate, for: feedType)
                canUpdate = true
                
            }
            
        case .archive:
            
            guard let index = getMessageIndexById(feedType: feedType, messageId: message.messageId) else {
                return canUpdate
            }
            
            let message = archive.messages[index]
            
            // Read the message
            if !message.isRead {
                message.setRead()
                await delegate?.onMessageEvent(message, at: index, to: feedType, event: .read)
                await delegate?.onMessagesChanged(archive.messages, archive.canPaginate, for: feedType)
                canUpdate = true
            }
            
        }
        
        // Perform server update
        if canUpdate {
            do {
                try await client?.inbox.read(messageId: message.messageId)
            } catch {
                client?.log(error.localizedDescription)
                await reloadSnapshot(snapshot)
            }
        }
        
        return canUpdate
        
    }
    
    /// Unreads a message at a specific index in the specified dataset
    /// - Returns: `true` if successful, `false` if index is invalid
    @discardableResult
    func unreadMessage(_ message: InboxMessage, from feedType: InboxMessageFeed, client: CourierClient?) async -> Bool {
        
        let snapshot = getSnapshot()
        var canUpdate = false
        
        switch feedType {
        case .feed:
            
            guard let index = getMessageIndexById(feedType: feedType, messageId: message.messageId) else {
                return canUpdate
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
                await delegate?.onMessagesChanged(feed.messages, feed.canPaginate, for: feedType)
                canUpdate = true
                
            }
            
        case .archive:
            
            guard let index = getMessageIndexById(feedType: feedType, messageId: message.messageId) else {
                return canUpdate
            }
            
            let message = archive.messages[index]
            
            // Read the message
            if message.isRead {
                message.setUnread()
                await delegate?.onMessageEvent(message, at: index, to: feedType, event: .unread)
                await delegate?.onMessagesChanged(archive.messages, archive.canPaginate, for: feedType)
                canUpdate = true
            }
            
        }
        
        if canUpdate {
            do {
                try await client?.inbox.unread(messageId: message.messageId)
            } catch {
                client?.log(error.localizedDescription)
                await reloadSnapshot(snapshot)
            }
        }
        
        return canUpdate
        
    }
    
    /// Clicks a message at a specific index in the specified dataset
    /// - Returns: `true` if successful, `false` if index is invalid
    @discardableResult
    func clickMessage(_ message: InboxMessage, from feedType: InboxMessageFeed, client: CourierClient?) async -> Bool {
        
        var trackingId: String?
        
        switch feedType {
        case .feed:
            
            guard let index = getMessageIndexById(feedType: feedType, messageId: message.messageId) else {
                return false
            }
            
            let message = feed.messages[index]
            trackingId = message.clickTrackingId
            
        case .archive:
            
            guard let index = getMessageIndexById(feedType: feedType, messageId: message.messageId) else {
                return false
            }
            
            let message = archive.messages[index]
            trackingId = message.clickTrackingId
            
        }
        
        // Perform server update
        if let trackingId = trackingId {
            do {
                try await client?.inbox.click(messageId: message.messageId, trackingId: trackingId)
            } catch {
                client?.log(error.localizedDescription)
            }
        }
        
        return trackingId != nil
        
    }

    /// Archives a message at a specific index in the specified dataset
    /// - Returns: `true` if successful, `false` if index is invalid
    @discardableResult
    func archiveMessage(_ message: InboxMessage, from feedType: InboxMessageFeed, client: CourierClient?) async -> Bool {
        
        let snapshot = getSnapshot()
        var canUpdate = false
        
        switch feedType {
        case .feed:
            
            guard let index = getMessageIndexById(feedType: feedType, messageId: message.messageId) else {
                return canUpdate
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
            await delegate?.onMessagesChanged(feed.messages, feed.canPaginate, for: .feed)
            
            // Create copy
            message.setArchived()
            let newMessage = message.copy()
            
            // Add the item to the archive
            let insertIndex = findInsertIndex(for: newMessage, in: archive.messages)
            archive.messages.insert(newMessage, at: insertIndex)
            await delegate?.onMessageEvent(newMessage, at: insertIndex, to: .archive, event: .added)
            
            // Update feed total counts
            archive.totalCount += 1
            await delegate?.onTotalCountUpdated(totalCount: archive.totalCount, to: .archive)
            await delegate?.onMessagesChanged(archive.messages, archive.canPaginate, for: .archive)
            
            canUpdate = true
            
        case .archive:
            return canUpdate
        }
        
        if canUpdate {
            do {
                try await client?.inbox.archive(messageId: message.messageId)
            } catch {
                client?.log(error.localizedDescription)
                await reloadSnapshot(snapshot)
            }
        }
        
        return canUpdate
        
    }
    
    /// Opens a message at a specific index in the specified dataset
    /// - Returns: `true` if successful, `false` if index is invalid
    @discardableResult
    func openMessage(_ message: InboxMessage, from feedType: InboxMessageFeed, client: CourierClient?) async -> Bool {
        
        let snapshot = getSnapshot()
        
        var canUpdate = false
        
        switch feedType {
        case .feed:
            
            guard let index = getMessageIndexById(feedType: feedType, messageId: message.messageId) else {
                return canUpdate
            }
            
            let message = feed.messages[index]
            
            // Read the message
            if !message.isOpened {
                message.setOpened()
                await delegate?.onMessageEvent(message, at: index, to: feedType, event: .opened)
                await delegate?.onMessagesChanged(feed.messages, feed.canPaginate, for: feedType)
                canUpdate = true
            }
            
        case .archive:
            
            guard let index = getMessageIndexById(feedType: feedType, messageId: message.messageId) else {
                return canUpdate
            }
            
            let message = archive.messages[index]
            
            // Read the message
            if !message.isOpened {
                message.setOpened()
                await delegate?.onMessageEvent(message, at: index, to: feedType, event: .opened)
                await delegate?.onMessagesChanged(archive.messages, archive.canPaginate, for: feedType)
                canUpdate = true
            }
            
        }
        
        if canUpdate {
            do {
                try await client?.inbox.open(messageId: message.messageId)
            } catch {
                client?.log(error.localizedDescription)
                await reloadSnapshot(snapshot)
            }
        }
        
        return canUpdate
        
    }

    /// Reads all the messages
    @discardableResult
    func readAllMessages(client: CourierClient?) async -> Bool {
        
        let snapshot = getSnapshot()
        
        // Read all messages
        for (index, message) in feed.messages.enumerated() {
            if !message.isRead {
                message.setRead()
                await delegate?.onMessageEvent(message, at: index, to: .feed, event: .read)
            }
        }
        
        for (index, message) in archive.messages.enumerated() {
            if !message.isRead {
                message.setRead()
                await delegate?.onMessageEvent(message, at: index, to: .archive, event: .read)
            }
        }
        
        // Update unread count
        unreadCount = 0
        await delegate?.onUnreadCountUpdated(unreadCount: unreadCount)
        await delegate?.onMessagesChanged(feed.messages, feed.canPaginate, for: .feed)
        await delegate?.onMessagesChanged(archive.messages, archive.canPaginate, for: .archive)
        
        do {
            try await client?.inbox.readAll()
        } catch {
            client?.log(error.localizedDescription)
            await reloadSnapshot(snapshot)
        }
        
        return true
        
    }
    
    /// Add page of messages
    func addPage(_ page: InboxMessageSet, for feedType: InboxMessageFeed) async {
        switch feedType {
        case .feed:
            feed.totalCount = page.totalCount
            feed.canPaginate = page.canPaginate
            feed.paginationCursor = page.paginationCursor
            feed.messages.append(contentsOf: page.messages)
            await delegate?.onPageAdded(page.messages, page.canPaginate, isFirstPage: false, for: feedType)
            await delegate?.onTotalCountUpdated(totalCount: feed.totalCount, to: feedType)
            await delegate?.onMessagesChanged(feed.messages, feed.canPaginate, for: feedType)
        case .archive:
            archive.totalCount = page.totalCount
            archive.canPaginate = page.canPaginate
            archive.paginationCursor = page.paginationCursor
            archive.messages.append(contentsOf: page.messages)
            await delegate?.onPageAdded(page.messages, page.canPaginate, isFirstPage: false, for: feedType)
            await delegate?.onTotalCountUpdated(totalCount: archive.totalCount, to: feedType)
            await delegate?.onMessagesChanged(archive.messages, archive.canPaginate, for: feedType)
        }
    }
    
    /// Insert new messages
    func updateDataSet(_ data: InboxMessageSet, for feedType: InboxMessageFeed) async {
        switch feedType {
        case .feed:
            feed = data
            await delegate?.onTotalCountUpdated(totalCount: feed.totalCount, to: feedType)
            await delegate?.onPageAdded(data.messages, data.canPaginate, isFirstPage: true, for: feedType)
            await delegate?.onMessagesChanged(feed.messages, feed.canPaginate, for: feedType)
        case .archive:
            archive = data
            await delegate?.onTotalCountUpdated(totalCount: archive.totalCount, to: feedType)
            await delegate?.onPageAdded(data.messages, data.canPaginate, isFirstPage: true, for: feedType)
            await delegate?.onMessagesChanged(archive.messages, archive.canPaginate, for: feedType)
        }
    }
    
    /// Update unread count
    func updateUnreadCount(_ count: Int) async {
        unreadCount = count
        await delegate?.onUnreadCountUpdated(unreadCount: count)
    }
    
    /// Removes and resets everything
    func dispose() async {
        await updateDataSet(InboxMessageSet(), for: .feed)
        await updateDataSet(InboxMessageSet(), for: .archive)
        await updateUnreadCount(0)
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
