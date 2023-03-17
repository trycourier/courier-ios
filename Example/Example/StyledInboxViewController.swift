//
//  StyledInboxViewController.swift
//  Example
//
//  Created by https://github.com/mikemilla on 3/14/23.
//

import UIKit
import Courier

class StyledInboxViewController: UIViewController, CourierInboxDelegate {
    
    private let textColor = UIColor(red: 42 / 255, green: 21 / 255, blue: 55 / 255, alpha: 100)
    private let primaryColor = UIColor(red: 136 / 255, green: 45 / 255, blue: 185 / 255, alpha: 100)
    private let secondaryColor = UIColor(red: 234 / 255, green: 104 / 255, blue: 102 / 255, alpha: 100)
    
    private lazy var courierInbox = {
        return CourierInbox(
            lightTheme: CourierInboxTheme(
                brandId: "EK44JHXWFX4A9AGC8QWVNTBDTKC2",
                messageAnimationStyle: .fade,
                loadingIndicatorColor: primaryColor,
                titleFont: CourierInboxFont(
                    font: UIFont(name: "Avenir Black", size: 20)!,
                    color: textColor
                ),
                timeFont: CourierInboxFont(
                    font: UIFont(name: "Avenir Medium", size: 16)!,
                    color: textColor
                ),
                bodyFont: CourierInboxFont(
                    font: UIFont(name: "Avenir Medium", size: 18)!,
                    color: textColor
                ),
                detailTitleFont: CourierInboxFont(
                    font: UIFont(name: "Avenir Medium", size: 20)!,
                    color: textColor
                ),
                buttonStyles: CourierInboxButtonStyles(
                    font: CourierInboxFont(
                        font: UIFont(name: "Avenir Black", size: 16)!,
                        color: .white
                    ),
                    backgroundColor: primaryColor,
                    cornerRadius: 100
                ),
                cellStyles: CourierInboxCellStyles(
                    separatorStyle: .singleLine,
                    separatorInsets: .zero
                )
            ),
            darkTheme: CourierInboxTheme(
                brandId: "EK44JHXWFX4A9AGC8QWVNTBDTKC2",
                messageAnimationStyle: .right,
                unreadIndicatorBarColor: primaryColor,
                loadingIndicatorColor: .white,
                titleFont: CourierInboxFont(
                    font: UIFont(name: "Avenir Black", size: 20)!,
                    color: .white
                ),
                timeFont: CourierInboxFont(
                    font: UIFont(name: "Avenir Medium", size: 16)!,
                    color: .white
                ),
                bodyFont: CourierInboxFont(
                    font: UIFont(name: "Avenir Medium", size: 18)!,
                    color: .white
                ),
                detailTitleFont: CourierInboxFont(
                    font: UIFont(name: "Avenir Medium", size: 20)!,
                    color: .white
                ),
                buttonStyles: CourierInboxButtonStyles(
                    font: CourierInboxFont(
                        font: UIFont(name: "Avenir Black", size: 16)!,
                        color: primaryColor
                    ),
                    backgroundColor: .white,
                    cornerRadius: 0
                ),
                cellStyles: CourierInboxCellStyles(
                    separatorStyle: .none
                )
            )
        )
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

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
    
    func didClickInboxActionForMessageAtIndex(action: InboxAction, message: InboxMessage, index: Int) {
        print(action, message, index)
    }
    
    func didScrollInbox(scrollView: UIScrollView) {
//         print(scrollView.contentOffset.y)
    }

}
