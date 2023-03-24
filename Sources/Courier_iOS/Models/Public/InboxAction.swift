//
//  InboxAction.swift
//  
//
//  Created by https://github.com/mikemilla on 3/16/23.
//

import Foundation

@objc public class InboxAction: NSObject, Codable {
    
    // MARK: Properties
    
    @objc public let content: String?
    @objc public let href: String?
    @objc public let style: String?
    @objc public let background_color: String?
    
    public init(content: String?, href: String?, style: String?, background_color: String?) {
        self.content = content
        self.href = href
        self.style = style
        self.background_color = background_color
    }
    
}
