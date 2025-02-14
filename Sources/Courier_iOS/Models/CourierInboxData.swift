//
//  CourierInboxData.swift
//  Courier_iOS
//
//  Created by https://github.com/mikemilla on 9/30/24.
//

//
//  CourierInboxData.swift
//  Courier_iOS
//
//  Created by https://github.com/mikemilla on 9/30/24.
//

@CourierActor public class CourierInboxData {
    
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
    
    private func getMessageActor(for messageId: String) -> (InboxMessageFeed, InboxMessageActor)? {
        if let message = feed.messages.first(where: { $0.messageId == messageId }) {
            return (.feed, InboxMessageActor(message: message))
        } else if let message = archived.messages.first(where: { $0.messageId == messageId }) {
            return (.archived, InboxMessageActor(message: message))
        } else {
            return nil
        }
    }
    
    internal func updateUnreadCount(count: Int) {
        self.unreadCount = count
    }
    
    internal func addMessage(at index: Int, in feed: InboxMessageFeed, with message: InboxMessage) {
        if feed == .feed {
            self.feed.messages.insert(message, at: index)
            self.unreadCount += 1
        } else {
            self.archived.messages.insert(message, at: index)
        }
    }
    
    internal func updateMessage(messageId: String, event: InboxEventType, handler: InboxMutationHandler) async throws {
        
        guard let (inboxFeed, messageActor) = getMessageActor(for: messageId) else {
            return
        }
        
        guard let index = feed.messages.firstIndex(where: { $0.messageId == messageId }) ??
                          archived.messages.firstIndex(where: { $0.messageId == messageId }) else {
            return
        }
        
        let original = copy()
        
        let canUpdateServerData = await mutateLocalData(with: messageActor, event: event, inboxFeed: inboxFeed, index: index, handler: handler)
        
        if !canUpdateServerData {
            return
        }
        
        do {
            let message = await messageActor.getMessage()
            try await mutateServerData(for: message, event: event)
        } catch {
            Courier.shared.client?.options.log(error.localizedDescription)
            await handler.onInboxReset(inbox: original, error: error)
        }
    }
    
    internal func readAllMessages(handler: InboxMutationHandler) async throws {
        
        // Copy the original state of the data
        let original = copy()
        
        await readAll(handler)
        
        let client = Courier.shared.client
        
        do {
            try await client?.inbox.readAll()
        } catch {
            client?.options.log(error.localizedDescription)
            await handler.onInboxReset(inbox: original, error: error)
        }
        
    }
    
    private func readAll(_ handler: InboxMutationHandler) async {
        feed.messages.forEach { $0.setRead() }
        archived.messages.forEach { $0.setRead() }
        await handler.onInboxUpdated(inbox: self)
        await handler.onUnreadCountChange(count: 0)
    }
    
    private func mutateLocalData(with messageActor: InboxMessageActor, event: InboxEventType, inboxFeed: InboxMessageFeed, index: Int, handler: InboxMutationHandler) async -> Bool {
        switch event {
        case .read:        return await read(messageActor, index, inboxFeed, handler)
        case .unread:      return await unread(messageActor, index, inboxFeed, handler)
        case .opened:      return await open(messageActor, index, inboxFeed, handler)
        case .unopened:    return await unopen(messageActor, index, inboxFeed, handler)
        case .archive:     return await archive(messageActor, index, inboxFeed, handler)
        case .unarchive:   return await unarchive(messageActor, index, inboxFeed, handler)
        case .click:       return await click(messageActor, index, inboxFeed, handler)
        case .unclick:     return false
        case .markAllRead: return false
        }
    }
    
    private func mutateServerData(for message: InboxMessage, event: InboxEventType) async throws {
        let client = Courier.shared.client
        switch event {
        case .read:
            try await client?.inbox.read(messageId: message.messageId)
        case .unread:
            try await client?.inbox.unread(messageId: message.messageId)
        case .opened:
            try await client?.inbox.open(messageId: message.messageId)
        case .unopened:
            break
        case .archive:
            try await client?.inbox.archive(messageId: message.messageId)
        case .unarchive:
            break
        case .click:
            if let channelId = message.trackingIds?.clickTrackingId {
                try await client?.inbox.click(messageId: message.messageId, trackingId: channelId)
            }
        case .unclick:
            break
        case .markAllRead:
            break
        }
    }
    
    private func open(_ messageActor: InboxMessageActor, _ index: Int, _ inboxFeed: InboxMessageFeed, _ handler: InboxMutationHandler) async -> Bool {
        let wasOpened = await messageActor.markOpened()
        if wasOpened {
            let updatedMessage = await messageActor.getMessage()
            await handler.onInboxItemUpdated(at: index, in: inboxFeed, with: updatedMessage)
        }
        return wasOpened
    }

    private func unopen(_ messageActor: InboxMessageActor, _ index: Int, _ inboxFeed: InboxMessageFeed, _ handler: InboxMutationHandler) async -> Bool {
        let wasUnopened = await messageActor.markUnopened()
        if wasUnopened {
            let updatedMessage = await messageActor.getMessage()
            await handler.onInboxItemUpdated(at: index, in: inboxFeed, with: updatedMessage)
        }
        return wasUnopened
    }
    
    private func read(_ messageActor: InboxMessageActor, _ index: Int, _ inboxFeed: InboxMessageFeed, _ handler: InboxMutationHandler) async -> Bool {
        let wasRead = await messageActor.markRead()
        if wasRead {
            let updatedMessage = await messageActor.getMessage()
            await handler.onInboxItemUpdated(at: index, in: inboxFeed, with: updatedMessage)
            unreadCount = max(unreadCount - 1, 0)
            await handler.onUnreadCountChange(count: unreadCount)
        }
        return wasRead
    }
    
    private func unread(_ messageActor: InboxMessageActor, _ index: Int, _ inboxFeed: InboxMessageFeed, _ handler: InboxMutationHandler) async -> Bool {
        let wasUnread = await messageActor.markUnread()
        if wasUnread {
            let updatedMessage = await messageActor.getMessage()
            await handler.onInboxItemUpdated(at: index, in: inboxFeed, with: updatedMessage)
            unreadCount += 1
            await handler.onUnreadCountChange(count: unreadCount)
        }
        return wasUnread
    }
    
    private func archive(_ messageActor: InboxMessageActor, _ index: Int, _ inboxFeed: InboxMessageFeed, _ handler: InboxMutationHandler) async -> Bool {
        let wasArchived = await messageActor.markArchived()
        if wasArchived {
            await handler.onInboxItemRemove(at: index, in: inboxFeed, with: await messageActor.getMessage())
        }
        return wasArchived
    }

    private func unarchive(_ messageActor: InboxMessageActor, _ index: Int, _ inboxFeed: InboxMessageFeed, _ handler: InboxMutationHandler) async -> Bool {
        let wasUnarchived = await messageActor.markUnarchived()
        if wasUnarchived {
            let updatedMessage = await messageActor.getMessage()
            await handler.onInboxItemAdded(at: index, in: inboxFeed, with: updatedMessage)
        }
        return wasUnarchived
    }
    
    private func click(_ messageActor: InboxMessageActor, _ index: Int, _ inboxFeed: InboxMessageFeed, _ handler: InboxMutationHandler) async -> Bool {
        return true
    }
    
}

// MARK: - Thread-Safe InboxMessage Actor

private actor InboxMessageActor {
    private var message: InboxMessage

    init(message: InboxMessage) {
        self.message = message
    }

    func getMessage() -> InboxMessage {
        return message
    }

    func markRead() -> Bool {
        if !message.isRead {
            message.setRead()
            return true
        }
        return false
    }

    func markUnread() -> Bool {
        if message.isRead {
            message.setUnread()
            return true
        }
        return false
    }

    func markOpened() -> Bool {
        if !message.isOpened {
            message.setOpened()
            return true
        }
        return false
    }

    func markUnopened() -> Bool {
        if message.isOpened {
            message.setUnopened()
            return true
        }
        return false
    }

    func markArchived() -> Bool {
        if !message.isArchived {
            message.setArchived()
            return true
        }
        return false
    }

    func markUnarchived() -> Bool {
        if message.isArchived {
            message.setUnarchived()
            return true
        }
        return false
    }
}


public struct InboxMessageSet: Codable {
    internal(set) public var messages: [InboxMessage]
    internal(set) public var totalCount: Int
    internal(set) public var canPaginate: Bool
    internal(set) public var paginationCursor: String?
}
