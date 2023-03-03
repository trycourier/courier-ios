//
//  RootTabBarController.swift
//  Example
//
//  Created by Michael Miller on 3/3/23.
//

import UIKit
import Courier

class RootTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Courier.shared.inboxPaginationLimit = 1

        Courier.shared.addInboxListener(
            onMessagesChanged: { _, _, totalMessageCount, _ in
                
                self.tabBar.items?[1].badgeValue = "\(totalMessageCount)"
                
                
            }
        )
        
    }

}
