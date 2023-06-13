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
        
        courierInbox.didClickInboxMessageAtIndex = { message, index in
            print(index, message)
            message.isRead ? message.markAsUnread() : message.markAsRead()
        }
        
        courierInbox.didClickInboxActionForMessageAtIndex = { action, message, index in
            print(action, message, index)
        }
        
        title = "Prebuilt Inbox"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Read All", style: .plain, target: self, action: #selector(readAll))
        
    }
    
    @objc private func readAll() {
        Courier.shared.readAllInboxMessages()
    }

}
