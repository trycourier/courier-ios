//
//  RootTabBarController.swift
//  Example
//
//  Created by https://github.com/mikemilla on 3/3/23.
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
        let tabTitle = count <= 0 ? nil : "\(count)"
        self.tabBar.items?[1].badgeValue = tabTitle
        self.tabBar.items?[2].badgeValue = tabTitle
        self.tabBar.items?[3].badgeValue = tabTitle
        UIApplication.shared.applicationIconBadgeNumber = count
    }
    
    deinit {
        self.inboxListener?.remove()
    }

}
