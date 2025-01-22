//
//  InboxEventType.swift
//  Courier_iOS
//
//  Created by https://github.com/mikemilla on 1/22/25.
//

internal enum InboxEventType: String, Codable {
    case markAllRead = "mark-all-read"
    case read = "read"
    case unread = "unread"
    case opened = "opened"
    case unopened = "unopened"
    case archive = "archive"
    case unarchive = "unarchive"
    case click = "click"
    case unclick = "unclick"
}
