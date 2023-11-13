//
//  StyledInboxViewController.swift
//  Example
//
//  Created by https://github.com/mikemilla on 3/14/23.
//

import UIKit
import Courier_iOS

class StyledInboxViewController: UIViewController {
    
    private let textColor = UIColor(red: 42 / 255, green: 21 / 255, blue: 55 / 255, alpha: 100)
    private let primaryColor = UIColor(red: 136 / 255, green: 45 / 255, blue: 185 / 255, alpha: 100)
    private let secondaryColor = UIColor(red: 234 / 255, green: 104 / 255, blue: 102 / 255, alpha: 100)
    
    private lazy var courierInbox = {
        return CourierInbox(
            lightTheme: CourierInboxTheme(
                messageAnimationStyle: .fade,
                loadingIndicatorColor: secondaryColor,
                unreadIndicator: CourierInboxUnreadIndicator(
                    style: .dot,
                    color: secondaryColor
                ),
                titleStyles: CourierInboxTextStyles(
                    unread: CourierInboxFont(
                        font: UIFont(name: "Avenir Black", size: 20)!,
                        color: textColor
                    ),
                    read: CourierInboxFont(
                        font: UIFont(name: "Avenir Black", size: 20)!,
                        color: textColor
                    )
                ),
                timeFont: CourierInboxFont(
                    font: UIFont(name: "Avenir Medium", size: 18)!,
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
                unreadIndicator: CourierInboxUnreadIndicator(
                    style: .dot
                ),
                titleStyles: CourierInboxTextStyles(
                    unread: CourierInboxFont(
                        font: UIFont(name: "Avenir Black", size: 20)!,
                        color: .white
                    ),
                    read: CourierInboxFont(
                        font: UIFont(name: "Avenir Black", size: 20)!,
                        color: .gray
                    )
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
                        color: .white
                    ),
                    cornerRadius: 0
                ),
                cellStyles: CourierInboxCellStyles(
                    separatorStyle: .none
                )
            ),
            didClickInboxMessageAtIndex: { message, index in
                
                message.isRead ? message.markAsUnread() : message.markAsRead()
                
                print(message.toJson() ?? "")
                
            },
            didClickInboxActionForMessageAtIndex: { action, message, index in
                print(action.toJson() ?? "")
            },
            didScrollInbox: { scrollView in
                print(scrollView.contentOffset.y)
            }
        )
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        courierInbox.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(courierInbox)
        
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

}
