//
//  CourierInboxData.swift
//  Courier_iOS
//
//  Created by Michael Miller on 9/30/24.
//

public class CourierInboxData {
    
    internal(set) public var feed: InboxMessageSet
    internal(set) public var archived: InboxMessageSet
    internal(set) public var unreadCount: Int
    
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
    
    private func getMessages(for messageId: String) -> (InboxMessageFeed, [InboxMessage])? {
        if let _ = feed.messages.first(where: { $0.messageId == messageId }) {
            return (.feed, feed.messages)
        } else if let _ = archived.messages.first(where: { $0.messageId == messageId }) {
            return (.archived, archived.messages)
        } else {
            return nil
        }
    }
    
    internal func readAllMessages(client: CourierClient?, handler: InboxMutationHandler) async throws {
        
        guard let client = client else {
            throw CourierError.inboxNotInitialized
        }
        
        // Copy the original state of the data
        let original = copy()
        
        await readAll(handler)
        
        do {
            try await client.inbox.readAll()
        } catch {
            client.options.log(error.localizedDescription)
            await handler.onInboxReset(inbox: original, error: error)
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
            await handler.onInboxReset(inbox: original, error: error)
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
    
    private func readAll(_ handler: InboxMutationHandler) async {
        feed.messages.forEach { $0.setRead() }
        archived.messages.forEach { $0.setRead() }
        await handler.onInboxUpdated(inbox: self)
        await handler.onUnreadCountChange(count: 0)
    }
    
    private func read(_ message: inout InboxMessage, _ index: Int, _ inboxFeed: InboxMessageFeed, _ handler: InboxMutationHandler) async {
        if !message.isRead {
            
            message.setRead()
            await handler.onInboxItemUpdated(at: index, in: inboxFeed, with: message)
            
            unreadCount = max(unreadCount - 1, 0)
            await handler.onUnreadCountChange(count: unreadCount)
        }
    }
    
    private func unread(_ message: inout InboxMessage, _ index: Int, _ inboxFeed: InboxMessageFeed, _ handler: InboxMutationHandler) async {
        if message.isRead {
            
            message.setUnread()
            await handler.onInboxItemUpdated(at: index, in: inboxFeed, with: message)
            
            unreadCount += 1
            await handler.onUnreadCountChange(count: unreadCount)
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
    
}

public struct InboxMessageSet {
    internal(set) public var messages: [InboxMessage]
    internal(set) public var totalCount: Int
    internal(set) public var canPaginate: Bool
    internal(set) public var paginationCursor: String?
}
