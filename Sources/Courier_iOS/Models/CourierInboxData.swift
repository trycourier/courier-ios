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
    
    internal init(messages: InboxMessageSet, archived: InboxMessageSet, unreadCount: Int) {
        self.feed = messages
        self.archived = archived
        self.unreadCount = unreadCount
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
    
    internal func addPage(_ inboxFeed: InboxMessageFeed, newMessages: [InboxMessage], startCursor: String?, hasNextPage: Bool?) {
        if inboxFeed == .archived {
            archived.messages.append(contentsOf: newMessages)
            archived.paginationCursor = startCursor
            archived.canPaginate = hasNextPage ?? false
        } else {
            feed.messages.append(contentsOf: newMessages)
            feed.paginationCursor = startCursor
            feed.canPaginate = hasNextPage ?? false
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
    
    @discardableResult
    internal func performDatastoreUpdateOperation(
        _ inboxFeed: InboxMessageFeed,
        messageId: String,
        event: InboxEventType
    ) throws -> UpdateOperation? {
        
        // Determine the message set based on inboxFeed
        var messages = inboxFeed == .archived ? archived.messages : feed.messages
        
        // Find the index of the message
        guard let index = messages.firstIndex(where: { $0.messageId == messageId }) else {
            return nil
        }

        // Process the message and return the update operation
        return try updateMessage(
            message: &messages[index],
            event: event,
            unreadCount: &unreadCount,
            index: index
        )
    }

    private func updateMessage(
        message: inout InboxMessage,
        event: InboxEventType,
        unreadCount: inout Int,
        index: Int
    ) throws -> UpdateOperation? {
        
        let originalMessage = message.copy()
        
        // Update based on action
        switch event {
        case .read:
            guard !message.isRead else { return nil }
            message.setRead()
            unreadCount = max(unreadCount - 1, 0)

        case .unread:
            guard message.isRead else { return nil }
            message.setUnread()
            unreadCount += 1

        case .opened:
            guard !message.isOpened else { return nil }
            message.setOpened()

        case .unopened:
            guard message.isOpened else { return nil }
            message.setUnopened()

        case .archive:
            guard !message.isArchived else { return nil }
            if !message.isRead {
                unreadCount = max(unreadCount - 1, 0)
            }
            message.setArchived()

        case .unarchive:
            guard message.isArchived else { return nil }
            if !message.isRead {
                unreadCount += 1
            }
            message.setUnarchived()

        case .click:
            // Implement any necessary logic for click event
            break
            
        case .unclick:
            // Implement any necessary logic for unclick event
            break

        case .markAllRead:
            // Implement any necessary logic for mark all read
            break
        }
        
        // Return the update operation with the index
        return UpdateOperation(
            index: index,
            unreadCount: unreadCount,
            message: originalMessage
        )
    }
    
    internal func resetUpdate(_ inboxFeed: InboxMessageFeed, update: UpdateOperation) {
        if inboxFeed == .archived {
            archived.messages[update.index] = update.message
        } else {
            feed.messages[update.index] = update.message
        }
        unreadCount = update.unreadCount
    }
    
    @discardableResult internal func readMessage(_ inboxFeed: InboxMessageFeed, messageId: String) throws -> UpdateOperation? {
        return try performDatastoreUpdateOperation(inboxFeed, messageId: messageId, event: .read)
    }
    
    @discardableResult internal func unreadMessage(_ inboxFeed: InboxMessageFeed, messageId: String) throws -> UpdateOperation? {
        return try performDatastoreUpdateOperation(inboxFeed, messageId: messageId, event: .unread)
    }
    
    @discardableResult internal func openMessage(_ inboxFeed: InboxMessageFeed, messageId: String) throws -> UpdateOperation? {
        return try performDatastoreUpdateOperation(inboxFeed, messageId: messageId, event: .opened)
    }
    
    @discardableResult internal func unopenMessage(_ inboxFeed: InboxMessageFeed, messageId: String) throws -> UpdateOperation? {
        return try performDatastoreUpdateOperation(inboxFeed, messageId: messageId, event: .unopened)
    }
    
    @discardableResult internal func archiveMessage(_ inboxFeed: InboxMessageFeed, messageId: String) throws -> UpdateOperation? {
        return try performDatastoreUpdateOperation(inboxFeed, messageId: messageId, event: .archive)
    }
    
    @discardableResult internal func unarchiveMessage(_ inboxFeed: InboxMessageFeed, messageId: String) throws -> UpdateOperation? {
        return try performDatastoreUpdateOperation(inboxFeed, messageId: messageId, event: .unarchive)
    }
    
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

public struct InboxMessageSet {
    public var messages: [InboxMessage]
    public var totalCount: Int
    public var canPaginate: Bool
    public var paginationCursor: String?
}
