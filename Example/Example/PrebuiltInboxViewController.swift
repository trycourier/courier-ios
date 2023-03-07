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
    
    func didClickInboxMessageAtIndex(message: InboxMessage, index: Int) {
        message.isRead ? message.markAsUnread() : message.markAsRead()
    }
    
    func didScrollInbox(scrollView: UIScrollView) {
        
        let distanceToBottom = scrollView.contentSize.height - scrollView.contentOffset.y
        
        print(distanceToBottom)

//        print(distanceToBottom, getPaginationTrigger())

//        if (distanceToBottom < getPaginationTrigger()) {
//            Courier.shared.fetchNextPageOfMessages()
//        }
    }

}
