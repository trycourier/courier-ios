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
    
    var isPaging = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Prebuilt Inbox"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Read All", style: .plain, target: self, action: #selector(readAll))
        
        courierInbox.delegate = self
        
    }
    
    @objc private func readAll() {
//        Courier.shared.readAllInboxMessages()
//        courierInbox.scrollToTop()
        
        if let table = courierInbox.table {
            
            table.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            
//            let point = CGPoint(
//                x: 0,
//                y: -scrollView.adjustedContentInset.top
//            )
//
//            scrollView.setContentOffset(point, animated: true)
            
        }
        
    }
    
    func didScrollInbox(scrollView: UIScrollView) {
        print(scrollView.contentOffset.y)
    }
    
    func didClickInboxMessageAtIndex(message: InboxMessage, index: Int) {
        message.isRead ? message.markAsUnread() : message.markAsRead()
    }

}
