//
//  CourierPushEvent.swift
//  
//
//  Created by https://github.com/mikemilla on 8/4/22.
//

import Foundation

// MARK: Public Classes

@objc public enum CourierPushEvent: Int, RawRepresentable {
    
    case clicked
    case delivered
    case opened
    case read
    case unread
    
    public typealias RawValue = String

    public var rawValue: RawValue {
        switch self {
        case .clicked:
            return "CLICKED"
        case .delivered:
            return "DELIVERED"
        case .opened:
            return "OPENED"
        case .read:
            return "READ"
        case .unread:
            return "UNREAD"
        }
    }

    public init?(rawValue: RawValue) {
        switch rawValue {
        case "CLICKED":
            self = .clicked
        case "DELIVERED":
            self = .delivered
        case "OPENED":
            self = .opened
        case "READ":
            self = .read
        case "UNREAD":
            self = .unread
        default:
            return nil
        }
    }
    
}
