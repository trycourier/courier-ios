//
//  CourierUserPreferences.swift
//
//
//  Created by https://github.com/mikemilla on 9/27/23.
//

import Foundation

// MARK: Public Classes

internal class CourierUserPreferencesTopicResponse: NSObject, Codable {
    
    public let topic: CourierUserPreferencesTopic
    
    internal init(topic: CourierUserPreferencesTopic) {
        self.topic = topic
    }
    
}

@objc public class CourierUserPreferences: NSObject, Codable {
    
    public let items: [CourierUserPreferencesTopic]
    public let paging: CourierUserPreferencesPaging
    
    internal init(items: [CourierUserPreferencesTopic], paging: CourierUserPreferencesPaging) {
        self.items = items
        self.paging = paging
    }
    
}



// MARK: Topic

@objc public class CourierUserPreferencesTopic: NSObject, Codable {
    
    public let customRouting: [CourierUserPreferencesChannel]
    @objc public let defaultStatus: CourierUserPreferencesStatus
    @objc public let status: CourierUserPreferencesStatus
    @objc public let hasCustomRouting: Bool
    @objc public let topicId: String
    @objc public let topicName: String
    @objc public let sectionName: String
    @objc public let sectionId: String
    
    private enum CodingKeys: String, CodingKey {
        case defaultStatus = "default_status"
        case hasCustomRouting = "has_custom_routing"
        case customRouting = "custom_routing"
        case status = "status"
        case topicId = "topic_id"
        case topicName = "topic_name"
        case sectionName = "section_name"
        case sectionId = "section_id"
    }
    
    @objc internal init(defaultStatus: String, hasCustomRouting: Bool, customRouting: [String], status: String, topicId: String, topicName: String, sectionName: String, sectionId: String) {
        self.defaultStatus = CourierUserPreferencesStatus(rawValue: defaultStatus) ?? .unknown
        self.hasCustomRouting = hasCustomRouting
        self.customRouting = customRouting.map { CourierUserPreferencesChannel(rawValue: $0) ?? .unknown }
        self.status = CourierUserPreferencesStatus(rawValue: status) ?? .unknown
        self.topicId = topicId
        self.topicName = topicName
        self.sectionName = sectionName
        self.sectionId = sectionId
    }
    
}

extension CourierUserPreferencesTopic {
    
    internal func isEqual(to other: CourierUserPreferencesTopic) -> Bool {
        return self.defaultStatus == other.defaultStatus &&
               self.status == other.status &&
               self.hasCustomRouting == other.hasCustomRouting &&
               self.topicId == other.topicId &&
               self.topicName == other.topicName &&
               self.customRouting == other.customRouting
    }
    
}

// MARK: Status

@objc public enum CourierUserPreferencesStatus: Int, RawRepresentable, Codable {
    
    case optedIn
    case optedOut
    case required
    case unknown
    
    public typealias RawValue = String

    public var rawValue: RawValue {
        switch self {
        case .optedIn:
            return "OPTED_IN"
        case .optedOut:
            return "OPTED_OUT"
        case .required:
            return "REQUIRED"
        case .unknown:
            return "UNKNOWN"
        }
    }

    public init?(rawValue: RawValue) {
        switch rawValue {
        case "OPTED_IN":
            self = .optedIn
        case "OPTED_OUT":
            self = .optedOut
        case "REQUIRED":
            self = .required
        default:
            self = .unknown
        }
    }
    
}

// MARK: Channel

@objc public enum CourierUserPreferencesChannel: Int, RawRepresentable, Codable {
    
    case directMessage
    case email
    case push
    case sms
    case webhook
    case unknown
    
    public typealias RawValue = String

    public var rawValue: RawValue {
        switch self {
        case .directMessage:
            return "direct_message"
        case .email:
            return "email"
        case .push:
            return "push"
        case .sms:
            return "sms"
        case .webhook:
            return "webhook"
        case .unknown:
            return "unknown"
        }
    }

    public init?(rawValue: RawValue) {
        switch rawValue {
        case "direct_message":
            self = .directMessage
        case "email":
            self = .email
        case "push":
            self = .push
        case "sms":
            self = .sms
        case "webhook":
            self = .webhook
        default:
            self = .unknown
        }
    }
    
    var title: String {
        switch self {
        case .directMessage:
            return "In App Messages"
        case .email:
            return "Emails"
        case .push:
            return "Push Notifications"
        case .sms:
            return "Text Messages"
        case .webhook:
            return "Webhooks"
        case .unknown:
            return "Unknown"
        }
    }
    
    public static var allCases: [CourierUserPreferencesChannel] {
        return [.push, .sms, .email, .directMessage, .webhook]
    }
    
}

// MARK: Pagination

@objc public class CourierUserPreferencesPaging: NSObject, Codable {
    
    public let cursor: String?
    public let more: Bool
    
    internal init(cursor: String? = nil, more: Bool) {
        self.cursor = cursor
        self.more = more
    }
    
}
