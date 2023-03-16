//
//  InboxAction.swift
//  
//
//  Created by Michael Miller on 3/16/23.
//

import Foundation

@objc public class InboxAction: NSObject, Codable {
    
    public let content: String?
    public let href: String?
    public let style: String?
    public let background_color: String?
    
    public init(content: String?, href: String?, style: String?, background_color: String?) {
        self.content = content
        self.href = href
        self.style = style
        self.background_color = background_color
    }
    
}
