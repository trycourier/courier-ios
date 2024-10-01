//
//  RootTabBarController.swift
//  Example
//
//  Created by https://github.com/mikemilla on 3/3/23.
//

import UIKit
import Courier_iOS

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
            onInboxChanged: { inbox in
                self.setBadge(inbox.unreadCount)
            }
        )
        
    }
    
    private func setBadge(_ count: Int) {
        Courier.requestNotificationPermission { status in
            DispatchQueue.main.async {
                let tabTitle = count <= 0 ? nil : "\(count)"
                self.tabBar.items?[2].badgeValue = tabTitle
                UNUserNotificationCenter.current().setBadgeCount(count)
            }
        }
    }
    
    deinit {
        self.inboxListener?.remove()
    }

}
