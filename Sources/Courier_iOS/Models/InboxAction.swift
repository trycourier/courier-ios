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
    public let data: [String: Any]?
    
    enum CodingKeys: String, CodingKey {
        case content
        case href
        case data
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        content = try values.decodeIfPresent(String.self, forKey: .content)
        href = try values.decodeIfPresent(String.self, forKey: .href)
        
        // Decode `data` as Data and then convert it to [String: Any]
        let data = try values.decodeIfPresent(Data.self, forKey: .data)
        if let data = data {
            self.data = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        } else {
            self.data = nil
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(content, forKey: .content)
        try container.encodeIfPresent(href, forKey: .href)
        
        // Convert `data` to Data and encode
        if let data = data {
            let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
            try container.encode(jsonData, forKey: .data)
        } else {
            try container.encodeNil(forKey: .data)
        }
    }
    
}
