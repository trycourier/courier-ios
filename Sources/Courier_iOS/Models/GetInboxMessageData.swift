//
//  GetInboxMessageData.swift
//
//
//  Created by https://github.com/mikemilla on 7/23/24.
//

import Foundation

@objc class GetInboxMessageData: NSObject {
    
    var message: InboxMessage?
    
    init(_ dictionary: [String : Any]?) {
        let message = dictionary?["message"] as? [String : Any]
        self.message = InboxMessage(message)
    }
    
}