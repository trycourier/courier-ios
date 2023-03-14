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
            messageAnimationStyle: .bottom,
            unreadIndicatorBarColor: .systemPink,
            loadingIndicatorColor: .systemGreen,
            titleFont: CourierInboxFont(
                font: UIFont.systemFont(ofSize: 20),
                color: .red
            ),
            timeFont: CourierInboxFont(
                font: UIFont.systemFont(ofSize: 30),
                color: .green
            ),
            bodyFont: CourierInboxFont(
                font: UIFont(name: "Al Nile Bold", size: 14)!,
                color: .blue
            ),
            detailTitleFont: CourierInboxFont(
                font: UIFont(name: "Al Nile Bold", size: 22)!,
                color: .green
            ),
            actionButtonFont: CourierInboxFont(
                font: UIFont(name: "Academy Engraved LET Plain:1.0", size: 13)!,
                color: .purple
            ),
            actionButtonBackgroundColor: .systemOrange,
            cellStyles: CourierInboxCellStyles(
                separatorStyle: .singleLine,
                separatorColor: .purple
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
