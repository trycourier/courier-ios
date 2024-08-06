//
//  InboxAction.swift
//  
//
//  Created by https://github.com/mikemilla on 3/16/23.
//

import Foundation

@objc public class InboxAction: NSObject {
    
    // MARK: Properties
    
    @objc public let content: String?
    @objc public let href: String?
    @objc public let data: [String: Any]?
    
    public init(content: String?, href: String?, data: [String: Any]?) {
        self.content = content
        self.href = href
        self.data = data
    }
    
}
