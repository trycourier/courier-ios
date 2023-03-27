//
//  PrebuiltInboxViewController.swift
//  Example
//
//  Created by https://github.com/mikemilla on 3/6/23.
//

import UIKit
import Courier_iOS

class PrebuiltInboxViewController: UIViewController {
    
    @IBOutlet weak var courierInbox: CourierInbox!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Prebuilt Inbox"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Read All", style: .plain, target: self, action: #selector(readAll))
        
        courierInbox.didClickInboxMessageAtIndex = { message, index in
            message.isRead ? message.markAsUnread() : message.markAsRead()
            print(index, message)
        }
        
        courierInbox.didClickInboxActionForMessageAtIndex = { action, message, index in
            print(action, message, index)
        }
        
    }
    
    @objc private func readAll() {
        Courier.shared.readAllInboxMessages()
    }

}
