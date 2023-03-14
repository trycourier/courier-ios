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
    
    var testConstraint: NSLayoutConstraint? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Prebuilt Inbox"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Read All", style: .plain, target: self, action: #selector(readAll))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Set Theme", style: .plain, target: self, action: #selector(setTheme))
        
        courierInbox.delegate = self
        
//        test()
        
    }
    
    @objc private func setTheme() {
        
        let theme = CourierInboxTheme(
            messageAnimationStyle: .right,
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
        
    }
    
    @objc private func readAll() {
        Courier.shared.readAllInboxMessages()
    }
    
    func didClickInboxMessageAtIndex(message: InboxMessage, index: Int) {
        message.isRead ? message.markAsUnread() : message.markAsRead()
        print(index, message)
//        print(courierInbox.table.adjustedContentInset)
//        testConstraint?.constant = -courierInbox.table.adjustedContentInset.bottom
//        bar.layoutIfNeeded()
        
    }
    
    func didClickButtonForInboxMessage(message: InboxMessage, index: Int) {
        print(index, message)
    }
    
    func didScrollInbox(scrollView: UIScrollView) {
        // print(scrollView.contentOffset.y)
    }
    
    let bar = UIView()
    
    private func test() {
        
        bar.backgroundColor = .green
        
        bar.translatesAutoresizingMaskIntoConstraints = false
        
        courierInbox.addSubview(bar)
        
//        let contentInset = courierInbox.table.adjustedContentInset
//        print(contentInset)
        
        testConstraint = bar.bottomAnchor.constraint(equalTo: courierInbox.bottomAnchor)
        testConstraint?.isActive = true
        bar.leadingAnchor.constraint(equalTo: courierInbox.leadingAnchor).isActive = true
        bar.trailingAnchor.constraint(equalTo: courierInbox.trailingAnchor).isActive = true
        bar.heightAnchor.constraint(equalToConstant: 48).isActive = true
        
    }

}
