//
//  CourierTrackingIds.swift
//
//
//  Created by https://github.com/mikemilla on 1/25/24.
//

import Foundation

public class CourierTrackingIds: Codable {
    public let archiveTrackingId: String?
    public let openTrackingId: String?
    public let clickTrackingId: String?
    public let deliverTrackingId: String?
    public let unreadTrackingId: String?
    public let readTrackingId: String?
}
