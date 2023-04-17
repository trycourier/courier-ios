//
//  InboxAction.swift
//  
//
//  Created by https://github.com/mikemilla on 3/16/23.
//

import Foundation

@objc public class InboxAction: NSObject, Codable {
    
    // TODO: Decode data by hand...
    
    // MARK: Properties
    
    @objc public let content: String?
    @objc public let href: String?
    @objc public let style: String?
    @objc public let backgroundColor: String?
    
    public init(content: String?, href: String?, style: String?, backgroundColor: String?) {
        self.content = content
        self.href = href
        self.style = style
        self.backgroundColor = backgroundColor
    }
    
    enum CodingKeys: String, CodingKey {
        case content
        case href
        case style
        case backgroundColor = "background_color"
    }
    
}
