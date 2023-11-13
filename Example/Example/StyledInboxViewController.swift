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
                unreadIndicatorStyle: CourierInboxUnreadIndicatorStyle(
                    indicator: .dot,
                    color: secondaryColor
                ),
                titleStyle: CourierInboxTextStyle(
                    unread: CourierInboxFont(
                        font: UIFont(name: "Avenir Black", size: 20)!,
                        color: textColor
                    ),
                    read: CourierInboxFont(
                        font: UIFont(name: "Avenir Black", size: 20)!,
                        color: textColor
                    )
                ),
                timeStyle: CourierInboxTextStyle(
                    unread: CourierInboxFont(
                        font: UIFont(name: "Avenir Medium", size: 18)!,
                        color: textColor
                    ),
                    read: CourierInboxFont(
                        font: UIFont(name: "Avenir Medium", size: 18)!,
                        color: textColor
                    )
                ),
                bodyStyle: CourierInboxTextStyle(
                    unread: CourierInboxFont(
                        font: UIFont(name: "Avenir Medium", size: 18)!,
                        color: textColor
                    ),
                    read: CourierInboxFont(
                        font: UIFont(name: "Avenir Medium", size: 18)!,
                        color: textColor
                    )
                ),
                buttonStyle: CourierInboxButtonStyle(
                    unread: CourierInboxButton(
                        font: CourierInboxFont(
                            font: UIFont(name: "Avenir Black", size: 16)!,
                            color: .white
                        ),
                        backgroundColor: primaryColor,
                        cornerRadius: 100
                    ),
                    read: CourierInboxButton(
                        font: CourierInboxFont(
                            font: UIFont(name: "Avenir Black", size: 16)!,
                            color: .white
                        ),
                        backgroundColor: primaryColor,
                        cornerRadius: 100
                    )
                ),
                cellStyle: CourierInboxCellStyle(
                    separatorStyle: .singleLine,
                    separatorInsets: .zero
                ),
                infoViewStyle: CourierInboxInfoViewStyle(
                    font: CourierInboxFont(
                        font: UIFont(name: "Avenir Medium", size: 20)!,
                        color: textColor
                    ),
                    button: CourierInboxButton(
                        font: CourierInboxFont(
                            font: UIFont(name: "Avenir Black", size: 16)!,
                            color: .white
                        ),
                        backgroundColor: primaryColor,
                        cornerRadius: 100
                    )
                )
            ),
            darkTheme: CourierInboxTheme(
                unreadIndicatorStyle: CourierInboxUnreadIndicatorStyle(
                    indicator: .dot
                ),
                titleStyle: CourierInboxTextStyle(
                    unread: CourierInboxFont(
                        font: UIFont(name: "Avenir Black", size: 20)!,
                        color: .white
                    ),
                    read: CourierInboxFont(
                        font: UIFont(name: "Avenir Black", size: 20)!,
                        color: .gray
                    )
                ),
                timeStyle: CourierInboxTextStyle(
                    unread: CourierInboxFont(
                        font: UIFont(name: "Avenir Medium", size: 16)!,
                        color: .white
                    ),
                    read: CourierInboxFont(
                        font: UIFont(name: "Avenir Medium", size: 16)!,
                        color: .gray
                    )
                ),
                bodyStyle: CourierInboxTextStyle(
                    unread: CourierInboxFont(
                        font: UIFont(name: "Avenir Medium", size: 18)!,
                        color: .white
                    ),
                    read: CourierInboxFont(
                        font: UIFont(name: "Avenir Medium", size: 18)!,
                        color: .gray
                    )
                ),
                buttonStyle: CourierInboxButtonStyle(
                    unread: CourierInboxButton(
                        font: CourierInboxFont(
                            font: UIFont(name: "Avenir Black", size: 16)!,
                            color: .white
                        ),
                        cornerRadius: 0
                    ),
                    read: CourierInboxButton(
                        font: CourierInboxFont(
                            font: UIFont(name: "Avenir Black", size: 16)!,
                            color: .white
                        ),
                        cornerRadius: 0
                    )
                ),
                cellStyle: CourierInboxCellStyle(
                    separatorStyle: .none
                ),
                infoViewStyle: CourierInboxInfoViewStyle(
                    font: CourierInboxFont(
                        font: UIFont(name: "Avenir Medium", size: 20)!,
                        color: .white
                    ),
                    button: CourierInboxButton(
                        font: CourierInboxFont(
                            font: UIFont(name: "Avenir Black", size: 16)!,
                            color: .white
                        ),
                        cornerRadius: 0
                    )
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
