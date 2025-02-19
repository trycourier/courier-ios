//
//  CourierMessageOpenManager.swift
//  Courier_iOS
//
//  Created by Michael Miller on 2/19/25.
//

import Foundation

internal actor CourierMessageOpenManager {
    private var inboxMessages: [InboxMessage] = []
    
    func getVisibleMessages(indices: [IndexPath]) -> [InboxMessage] {
        indices.compactMap { indexPath in
            let index = indexPath.row
            guard index >= 0 && index < inboxMessages.count else { return nil }
            let message = inboxMessages[index]
            return message.isOpened ? nil : message
        }
    }
}
