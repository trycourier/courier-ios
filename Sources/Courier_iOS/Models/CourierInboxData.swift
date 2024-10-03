//
//  CourierInboxData.swift
//  Courier_iOS
//
//  Created by Michael Miller on 9/30/24.
//

public class CourierInboxData {
    
    private(set) public var feed: InboxMessageSet
    private(set) public var archived: InboxMessageSet
    private(set) public var unreadCount: Int
    
    internal init(feed: InboxMessageSet, archived: InboxMessageSet, unreadCount: Int) {
        self.feed = feed
        self.archived = archived
        self.unreadCount = unreadCount
    }
    
    public func copy() -> CourierInboxData {
        return CourierInboxData(
            feed: self.feed,
            archived: self.archived,
            unreadCount: self.unreadCount
        )
    }
    
    internal func addNewMessage(_ inboxFeed: InboxMessageFeed, message: InboxMessage) {
        if inboxFeed == .archived {
            archived.messages.insert(message, at: 0)
            archived.totalCount += 1
        } else {
            feed.messages.insert(message, at: 0)
            feed.totalCount += 1
            unreadCount += 1
        }
    }
    
    internal func addPage(_ inboxFeed: InboxMessageFeed, messageSet: InboxMessageSet) {
        if inboxFeed == .archived {
            archived.messages.append(contentsOf: messageSet.messages)
            archived.paginationCursor = messageSet.paginationCursor
            archived.canPaginate = messageSet.canPaginate
        } else {
            feed.messages.append(contentsOf: messageSet.messages)
            feed.paginationCursor = messageSet.paginationCursor
            feed.canPaginate = messageSet.canPaginate
        }
    }
    
    private func getMessages(for messageId: String) -> (InboxMessageFeed, [InboxMessage])? {
        if let _ = feed.messages.first(where: { $0.messageId == messageId }) {
            return (.feed, feed.messages)
        } else if let _ = archived.messages.first(where: { $0.messageId == messageId }) {
            return (.archived, archived.messages)
        } else {
            return nil
        }
    }
    
    internal func updateMessage(messageId: String, event: InboxEventType, client: CourierClient?, handler: InboxMutationHandler) async throws {
        
        guard let client = client else {
            throw CourierError.inboxNotInitialized
        }
        
        let values = getMessages(for: messageId)
        let inboxFeed = values?.0
        var messages = values?.1
        
        if values == nil {
            return
        }
        
        // Get the current message
        guard let index = messages!.firstIndex(where: { $0.messageId == messageId }) else {
            return
        }
        
        // Copy the original state of the data
        let original = copy()
        
        // Change the local data
        await mutateLocalData(with: &messages![index], event: event, inboxFeed: inboxFeed!, index: index, handler: handler)
        
        // Perform server update
        // If fails, reset the change to the original copy
        do {
            try await mutateServerData(using: client, for: messages![index], event: event)
        } catch {
            client.options.log(error.localizedDescription)
            await handler.onInboxUpdated(inbox: original)
        }
        
    }
    
    private func mutateLocalData(with message: inout InboxMessage, event: InboxEventType, inboxFeed: InboxMessageFeed, index: Int, handler: InboxMutationHandler) async {
        switch event {
        case .read:        await read(&message, index, inboxFeed, handler)
        case .unread:      await unread(&message, index, inboxFeed, handler)
        case .opened:      await open(&message, index, inboxFeed, handler)
        case .unopened:    await unopen(&message, index, inboxFeed, handler)
        case .archive:     await archive(&message, index, inboxFeed, handler)
        case .unarchive:   break
        case .click:       break
        case .unclick:     break
        case .markAllRead: break
        }
    }
    
    private func mutateServerData(using client: CourierClient, for message: InboxMessage, event: InboxEventType) async throws {
        switch event {
        case .read:
            try await client.inbox.read(messageId: message.messageId)
        case .unread:
            try await client.inbox.unread(messageId: message.messageId)
        case .opened:
            try await client.inbox.open(messageId: message.messageId)
        case .unopened:
            break
        case .archive:
            try await client.inbox.archive(messageId: message.messageId)
        case .unarchive:
            break
        case .click:
            if let channelId = message.trackingIds?.clickTrackingId {
                try await client.inbox.click(messageId: message.messageId, trackingId: channelId)
            }
        case .unclick:
            break
        case .markAllRead:
            break
        }
    }
    
    private func read(_ message: inout InboxMessage, _ index: Int, _ inboxFeed: InboxMessageFeed, _ handler: InboxMutationHandler) async {
        if !message.isRead {
            message.setRead()
            unreadCount = max(unreadCount - 1, 0)
            await handler.onInboxItemUpdated(at: index, in: inboxFeed, with: message)
        }
    }
    
    private func unread(_ message: inout InboxMessage, _ index: Int, _ inboxFeed: InboxMessageFeed, _ handler: InboxMutationHandler) async {
        if message.isRead {
            message.setUnread()
            unreadCount += 1
            await handler.onInboxItemUpdated(at: index, in: inboxFeed, with: message)
        }
    }
    
    private func open(_ message: inout InboxMessage, _ index: Int, _ inboxFeed: InboxMessageFeed, _ handler: InboxMutationHandler) async {
        if !message.isOpened {
            message.setOpened()
            await handler.onInboxItemUpdated(at: index, in: inboxFeed, with: message)
        }
    }
    
    private func unopen(_ message: inout InboxMessage, _ index: Int, _ inboxFeed: InboxMessageFeed, _ handler: InboxMutationHandler) async {
        if message.isOpened {
            message.setUnopened()
            await handler.onInboxItemUpdated(at: index, in: inboxFeed, with: message)
        }
    }
    
    private func archive(_ message: inout InboxMessage, _ index: Int, _ inboxFeed: InboxMessageFeed, _ handler: InboxMutationHandler) async {
        if !message.isArchived {
            
            // Read the message
            await read(&message, index, inboxFeed, handler)
            
            // Change archived status
            message.setArchived()
            await handler.onInboxItemUpdated(at: index, in: inboxFeed, with: message)
            
            // Create copy
            let newMessage = message.copy()
            
            // Remove the item from the feed
            feed.messages.remove(at: index)
            await handler.onInboxItemRemove(at: index, in: .feed, with: message)
            
            // Add the item to the archive
            if let insertIndex = findInsertIndex(for: newMessage, in: archived.messages) {
                archived.messages.insert(newMessage, at: insertIndex)
                await handler.onInboxItemRemove(at: insertIndex, in: .archived, with: message)
            }
            
        }
    }
    
    @discardableResult internal func readAllMessages(_ inboxFeed: InboxMessageFeed) -> ReadAllOperation? {
        
        if (inboxFeed == .archived) {
            return nil
        }
        
        // Copy previous values
        let originalMessages = Array(feed.messages)
        let originalUnreadCount = unreadCount
        
        // Read all messages
        feed.messages.forEach { $0.setRead() }
        unreadCount = 0

        return ReadAllOperation(
            messages: originalMessages,
            unreadCount: originalUnreadCount
        )
        
    }
    
    internal func resetReadAll(_ inboxFeed: InboxMessageFeed, update: ReadAllOperation) {
        if inboxFeed == .archived {
            archived.messages = update.messages
        } else {
            feed.messages = update.messages
        }
        unreadCount = update.unreadCount
    }
    
    private func findInsertIndex(for newMessage: InboxMessage, in messages: [InboxMessage]) -> Int? {
        for (index, message) in messages.enumerated() {
            if newMessage.createdAt >= message.createdAt {
                return index
            }
        }
        return nil
    }
    
    private func findCurrentIndex(for message: InboxMessage, in messages: [InboxMessage]) -> Int? {
        for (index, message) in messages.enumerated() {
            if message.messageId == message.messageId {
                return index
            }
        }
        return nil
    }
    
    
//    @discardableResult
//    internal func performDatastoreUpdateOperation(
//        _ inboxFeed: InboxMessageFeed,
//        messageId: String,
//        event: InboxEventType
//    ) throws -> UpdateOperation? {
//        
//        // Determine the message set based on inboxFeed
//        var messages = inboxFeed == .archived ? archived.messages : feed.messages
//        
//        // Find the index of the message
//        guard let index = messages.firstIndex(where: { $0.messageId == messageId }) else {
//            return nil
//        }
//
//        // Process the message and return the update operation
//        return try updateMessage(
//            message: &messages[index],
//            event: event,
//            unreadCount: &unreadCount,
//            index: index
//        )
//    }
//    
//    private func findInsertIndex(for newMessage: InboxMessage, in messages: [InboxMessage]) -> Int {
//        for (index, message) in messages.enumerated() {
//            if newMessage.createdAt >= message.createdAt {
//                return index
//            }
//        }
//        return messages.count
//    }
//
//    private func updateMessage(
//        message: inout InboxMessage,
//        event: InboxEventType,
//        unreadCount: inout Int,
//        index: Int
//    ) throws -> UpdateOperation? {
//        
//        let originalMessage = message.copy()
//        
//        // Update based on action
//        switch event {
//        case .read:
//            guard !message.isRead else { return nil }
//            message.setRead()
//            unreadCount = max(unreadCount - 1, 0)
//
//        case .unread:
//            
//            guard message.isRead else { return nil }
//            message.setUnread()
//            
//            unreadCount += 1
//
//        case .opened:
//            
//            guard !message.isOpened else { return nil }
//            message.setOpened()
//
//        case .unopened:
//            
//            guard message.isOpened else { return nil }
//            message.setUnopened()
//
//        case .archive:
//            
//            guard !message.isArchived else { return nil }
//            
//            if !message.isRead {
//                unreadCount = max(unreadCount - 1, 0)
//            }
//            
//            message.setArchived()
//            
//            // Add the message at index
//            let insertIndex = findInsertIndex(for: message, in: archived.messages)
//            archived.messages.insert(message, at: insertIndex)
//
//        case .unarchive:
//            
//            guard message.isArchived else { return nil }
//            
//            if !message.isRead {
//                unreadCount += 1
//            }
//            
//            message.setUnarchived()
//            
//            // Add the message at index
//            let insertIndex = findInsertIndex(for: message, in: feed.messages)
//            feed.messages.insert(message, at: insertIndex)
//
//        case .click:
//            break
//        case .unclick:
//            break
//        case .markAllRead:
//            break
//        }
//        
//        // Return the update operation with the index
//        return UpdateOperation(
//            index: index,
//            unreadCount: unreadCount,
//            message: originalMessage
//        )
//    }
    
    internal func resetUpdate(_ inboxFeed: InboxMessageFeed, update: UpdateOperation) {
        if inboxFeed == .archived {
            archived.messages[update.index] = update.message
        } else {
            feed.messages[update.index] = update.message
        }
        unreadCount = update.unreadCount
    }
    
//    @discardableResult internal func readMessage(_ inboxFeed: InboxMessageFeed, messageId: String) throws -> UpdateOperation? {
//        return try performDatastoreUpdateOperation(inboxFeed, messageId: messageId, event: .read)
//    }
//    
//    @discardableResult internal func unreadMessage(_ inboxFeed: InboxMessageFeed, messageId: String) throws -> UpdateOperation? {
//        return try performDatastoreUpdateOperation(inboxFeed, messageId: messageId, event: .unread)
//    }
//    
//    @discardableResult internal func openMessage(_ inboxFeed: InboxMessageFeed, messageId: String) throws -> UpdateOperation? {
//        return try performDatastoreUpdateOperation(inboxFeed, messageId: messageId, event: .opened)
//    }
//    
//    @discardableResult internal func unopenMessage(_ inboxFeed: InboxMessageFeed, messageId: String) throws -> UpdateOperation? {
//        return try performDatastoreUpdateOperation(inboxFeed, messageId: messageId, event: .unopened)
//    }
//    
//    @discardableResult internal func archiveMessage(_ inboxFeed: InboxMessageFeed, messageId: String) throws -> UpdateOperation? {
//        return try performDatastoreUpdateOperation(inboxFeed, messageId: messageId, event: .archive)
//    }
//    
//    @discardableResult internal func unarchiveMessage(_ inboxFeed: InboxMessageFeed, messageId: String) throws -> UpdateOperation? {
//        return try performDatastoreUpdateOperation(inboxFeed, messageId: messageId, event: .unarchive)
//    }
    
}



internal struct ReadAllOperation {
    let messages: [InboxMessage]
    let unreadCount: Int
}

internal struct UpdateOperation {
    let index: Int
    let unreadCount: Int
    let message: InboxMessage
}

internal struct MutationOperation {
    let original: CourierInboxData
}

public struct InboxMessageSet {
    internal(set) public var messages: [InboxMessage]
    internal(set) public var totalCount: Int
    internal(set) public var canPaginate: Bool
    internal(set) public var paginationCursor: String?
}
