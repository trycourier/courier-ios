//
//  PrebuiltInboxViewController.swift
//  Example
//
//  Created by Michael Miller on 3/6/23.
//

import UIKit
import Courier

class PrebuiltInboxViewController: UIViewController, CourierInboxDelegate {
    
    @IBOutlet weak var courierInbox: CourierInbox!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Prebuilt Inbox"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Read All", style: .plain, target: self, action: #selector(readAll))
        
        courierInbox.delegate = self
        
    }
    
    @objc private func readAll() {
        Courier.shared.readAllInboxMessages()
    }
    
    func didClickInboxMessageAtIndex(message: InboxMessage, listItemIndex: Int) {
        message.isRead ? message.markAsUnread() : message.markAsRead()
        print(listItemIndex, message)
    }
    
    func didClickButtonForInboxMessage(message: InboxMessage, index: Int) {
        print(index, message)
    }

}
