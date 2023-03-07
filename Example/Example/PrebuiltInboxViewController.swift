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
        
        let safeAreaHeight = scrollView.safeAreaInsets.top + scrollView.safeAreaInsets.bottom
        let viewHeight = scrollView.bounds.height - safeAreaHeight
        let scrollY = scrollView.contentOffset.y + scrollView.safeAreaInsets.top
        let fullScrollDistance = scrollY + viewHeight
        let pageCalc = fullScrollDistance - scrollView.contentSize.height
        
        print(scrollY, fullScrollDistance, pageCalc)
        
        if (pageCalc >= 0) {
            Courier.shared.fetchNextPageOfMessages()
        }
        
    }

}
