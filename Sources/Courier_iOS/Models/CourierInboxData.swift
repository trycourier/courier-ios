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
        
        var set = inboxFeed == .archived ? archived : feed
        set.messages.insert(message, at: 0)
        set.totalCount += 1
        
        if (inboxFeed != .archived) {
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
        } else if inboxFeed == .feed {
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
        
        // Reference the correct message set based on inboxFeed
        let set = inboxFeed == .archived ? archived : feed
        
        // Find the index of the message
        guard let index = set.messages.firstIndex(where: { $0.messageId == messageId }) else {
            return nil
        }

        // Save copy of the original message and unread count
        let message = set.messages[index]
        let originalMessage = message.copy()
        let originalUnreadCount = unreadCount

        // Update based on action
        switch event {
        case .read:
            guard !message.isRead else { return nil }
            message.setRead()
            self.unreadCount = max(unreadCount - 1, 0)

        case .unread:
            guard message.isRead else { return nil }
            message.setUnread()
            self.unreadCount += 1

        case .opened:
            guard !message.isOpened else { return nil }
            message.setOpened()

        case .unopened:
            guard message.isOpened else { return nil }
            message.setUnopened()

        case .archive:
            guard !message.isArchived else { return nil }
            if !message.isRead {
                self.unreadCount = max(unreadCount - 1, 0)
            }
            message.setArchived()

        case .unarchive:
            guard message.isArchived else { return nil }
            if !message.isRead {
                self.unreadCount += 1
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

        // Change the message data in the original set
        if inboxFeed == .archived {
            archived.messages[index] = message
        } else {
            feed.messages[index] = message
        }

        return UpdateOperation(
            index: index,
            unreadCount: originalUnreadCount,
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
