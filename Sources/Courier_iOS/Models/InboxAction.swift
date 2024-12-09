//
//  InboxAction.swift
//  
//
//  Created by https://github.com/mikemilla on 3/16/23.
//

import Foundation

public struct InboxAction: Codable {
    
    public let content: String?
    public let href: String?
    public private(set) var data: [String: Any]?
    
    enum CodingKeys: String, CodingKey {
        case content
        case href
        case data
    }
    
    public init(content: String?, href: String?, data: [String: Any]?) {
        self.content = content
        self.href = href
        self.data = data
    }
    
    // Custom encoding for CodableValue
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(content, forKey: .content)
        try container.encode(href, forKey: .href)
        
        // Encode the data dictionary
        if let dataDict = data {
            let encodableDict = dataDict.mapValues { AnyCodable($0) }
            try container.encode(encodableDict, forKey: .data)
        } else {
            try container.encodeNil(forKey: .data)
        }
    }
    
    // Custom decoding for CodableValue
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.content = try container.decodeIfPresent(String.self, forKey: .content)
        self.href = try container.decodeIfPresent(String.self, forKey: .href)
        
        // Decode the data dictionary
        if let dataDict = try? container.decodeIfPresent([String: AnyCodable].self, forKey: .data) {
            self.data = dataDict.compactMapValues { $0.value }
        } else {
            self.data = nil
        }
    }
    
}
