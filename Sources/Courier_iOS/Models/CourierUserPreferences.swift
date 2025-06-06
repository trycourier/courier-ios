//
//  CourierUserPreferences.swift
//
//
//  Created by https://github.com/mikemilla on 9/27/23.
//

import Foundation

// MARK: Public Classes

internal class CourierUserPreferencesTopicResponse: Codable {
    public let topic: CourierUserPreferencesTopic
}

public class CourierUserPreferences: Codable {
    public let items: [CourierUserPreferencesTopic]
    public let paging: CourierUserPreferencesPaging
}

// MARK: Topic

public class CourierUserPreferencesTopic: Codable {
    
    public let customRouting: [CourierUserPreferencesChannel]
    public let defaultStatus: CourierUserPreferencesStatus
    public let status: CourierUserPreferencesStatus
    public let hasCustomRouting: Bool
    public let topicId: String
    public let topicName: String
    public let sectionName: String
    public let sectionId: String
    
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
    
    internal init(defaultStatus: String, hasCustomRouting: Bool, customRouting: [String], status: String, topicId: String, topicName: String, sectionName: String, sectionId: String) {
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

public enum CourierUserPreferencesStatus: String, Codable {
    
    case optedIn = "OPTED_IN"
    case optedOut = "OPTED_OUT"
    case required = "REQUIRED"
    case unknown = "UNKNOWN"
    
    // Custom initializer to handle decoding
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self = CourierUserPreferencesStatus(rawValue: rawValue) ?? .unknown
    }
    
    // Custom encode method for encoding
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.rawValue)
    }
    
    // Title property
    var title: String {
        switch self {
        case .optedIn:
            return "Opted In"
        case .optedOut:
            return "Opted Out"
        case .required:
            return "Required"
        case .unknown:
            return "Unknown"
        }
    }
}

// MARK: Channel

public enum CourierUserPreferencesChannel: String, Codable {
    
    case directMessage = "direct_message"
    case inbox
    case email
    case push
    case sms
    case webhook
    case unknown
    
    // Custom initializer to handle decoding
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self = CourierUserPreferencesChannel(rawValue: rawValue) ?? .unknown
    }
    
    // Custom encode method for encoding
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.rawValue)
    }
    
    // Title property
    var title: String {
        switch self {
        case .directMessage:
            return "In App Messages"
        case .inbox:
            return "Inbox"
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
    
    // Static property to return all cases
    public static var allCases: [CourierUserPreferencesChannel] {
        return [.push, .sms, .email, .directMessage, .inbox, .webhook]
    }
}

// MARK: Pagination

public class CourierUserPreferencesPaging: NSObject, Codable {
    public let cursor: String?
    public let more: Bool
}
