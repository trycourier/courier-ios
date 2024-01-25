//
//  File.swift
//  
//
//  Created by Michael Miller on 1/25/24.
//

import Foundation

@objc public class CourierTrackingIds: NSObject {
    
    // MARK: Properties
    
    @objc public let archiveTrackingId: String?
    @objc public let openTrackingId: String?
    @objc public let clickTrackingId: String?
    @objc public let deliverTrackingId: String?
    @objc public let unreadTrackingId: String?
    @objc public let readTrackingId: String?
    
    public init(archiveTrackingId: String?, openTrackingId: String?, clickTrackingId: String?, deliverTrackingId: String?, unreadTrackingId: String?, readTrackingId: String?) {
        self.archiveTrackingId = archiveTrackingId
        self.openTrackingId = openTrackingId
        self.clickTrackingId = clickTrackingId
        self.deliverTrackingId = deliverTrackingId
        self.unreadTrackingId = unreadTrackingId
        self.readTrackingId = readTrackingId
    }
    
}
