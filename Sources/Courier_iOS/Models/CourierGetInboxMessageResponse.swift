//
//  CourierGetInboxMessageResponse.swift
//
//
//  Created by Michael Miller on 7/23/24.
//

import Foundation

@objc class CourierGetInboxMessageResponse: NSObject {
    
    let data: GetInboxMessageData?
    
    init(_ dictionary: [String : Any]?) {
        let data = dictionary?["data"] as? [String: Any]
        self.data = GetInboxMessageData(data)
    }
    
}
