//
//  RootTabBarController.swift
//  Example
//
//  Created by Michael Miller on 3/3/23.
//

import UIKit
import Courier

class RootTabBarController: UITabBarController {
    
    private var inboxListener: CourierInboxListener? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        self.inboxListener = Courier.shared.addInboxListener(
            onInitialLoad: {
                self.setBadge(0)
            },
            onError: { _ in
                self.setBadge(0)
            },
            onMessagesChanged: { _, unreadCount, _, _ in
                self.setBadge(unreadCount)
            }
        )
        
    }
    
    private func setBadge(_ count: Int) {
        self.tabBar.items?[1].badgeValue = count <= 0 ? nil : "\(count)"
        UIApplication.shared.applicationIconBadgeNumber = count
    }
    
    deinit {
        self.inboxListener?.remove()
    }

}
