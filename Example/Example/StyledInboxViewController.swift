//
//  StyledInboxViewController.swift
//  Example
//
//  Created by Michael Miller on 3/14/23.
//

import UIKit
import Courier

class StyledInboxViewController: UIViewController, CourierInboxDelegate {
    
    let courierInbox = CourierInbox()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let theme = CourierInboxTheme(
            messageAnimationStyle: .left,
            unreadIndicatorBarColor: .systemPink,
            loadingIndicatorColor: .systemOrange,
            titleFont: CourierInboxFont(
                font: UIFont(name: "Helvetica", size: 24)!,
                color: .systemGray2
            ),
            timeFont: CourierInboxFont(
                font: UIFont(name: "Helvetica", size: 18)!,
                color: .systemGray4
            ),
            bodyFont: CourierInboxFont(
                font: UIFont(name: "Helvetica", size: 22)!,
                color: .systemGray3
            ),
            detailTitleFont: CourierInboxFont(
                font: UIFont(name: "Helvetica", size: 24)!,
                color: .systemGray2
            ),
            actionButtonFont: CourierInboxFont(
                font: UIFont(name: "Helvetica", size: 18)!,
                color: .white
            ),
            actionButtonBackgroundColor: .systemMint,
            cellStyles: CourierInboxCellStyles(
                separatorStyle: .none
            )
        )
        
        courierInbox.lightTheme = theme
        courierInbox.darkTheme = theme

        courierInbox.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(courierInbox)
        
        courierInbox.delegate = self
        
        NSLayoutConstraint.activate([
            courierInbox.topAnchor.constraint(equalTo: view.topAnchor),
            courierInbox.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            courierInbox.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            courierInbox.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        
        title = "Styled Inbox"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Read All", style: .plain, target: self, action: #selector(readAll))
        
    }
    
    @objc private func readAll() {
        Courier.shared.readAllInboxMessages()
    }
    
    func didClickInboxMessageAtIndex(message: InboxMessage, index: Int) {
        message.isRead ? message.markAsUnread() : message.markAsRead()
        print(index, message)
    }
    
    func didClickButtonForInboxMessage(message: InboxMessage, index: Int) {
        print(index, message)
    }
    
    func didScrollInbox(scrollView: UIScrollView) {
         print(scrollView.contentOffset.y)
    }

}
