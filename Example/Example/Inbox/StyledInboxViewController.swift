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
                brandId: Env.COURIER_BRAND_ID,
                messageAnimationStyle: .fade,
                unreadIndicatorStyle: CourierStyles.Inbox.UnreadIndicatorStyle(
                    indicator: .dot,
                    color: secondaryColor
                ),
                titleStyle: CourierStyles.Inbox.TextStyle(
                    unread: CourierStyles.Font(
                        font: UIFont(name: "Avenir Black", size: 20)!,
                        color: textColor
                    ),
                    read: CourierStyles.Font(
                        font: UIFont(name: "Avenir Black", size: 20)!,
                        color: textColor
                    )
                ),
                timeStyle: CourierStyles.Inbox.TextStyle(
                    unread: CourierStyles.Font(
                        font: UIFont(name: "Avenir Medium", size: 18)!,
                        color: textColor
                    ),
                    read: CourierStyles.Font(
                        font: UIFont(name: "Avenir Medium", size: 18)!,
                        color: textColor
                    )
                ),
                bodyStyle: CourierStyles.Inbox.TextStyle(
                    unread: CourierStyles.Font(
                        font: UIFont(name: "Avenir Medium", size: 18)!,
                        color: textColor
                    ),
                    read: CourierStyles.Font(
                        font: UIFont(name: "Avenir Medium", size: 18)!,
                        color: textColor
                    )
                ),
                buttonStyle: CourierStyles.Inbox.ButtonStyle(
                    unread: CourierStyles.Button(
                        font: CourierStyles.Font(
                            font: UIFont(name: "Avenir Black", size: 16)!,
                            color: .white
                        ),
                        backgroundColor: primaryColor,
                        cornerRadius: 100
                    ),
                    read: CourierStyles.Button(
                        font: CourierStyles.Font(
                            font: UIFont(name: "Avenir Black", size: 16)!,
                            color: .white
                        ),
                        backgroundColor: primaryColor,
                        cornerRadius: 100
                    )
                ),
                cellStyle: CourierStyles.Cell(
                    separatorStyle: .singleLine,
                    separatorInsets: .zero
                ),
                infoViewStyle: CourierStyles.Inbox.InfoViewStyle(
                    font: CourierStyles.Font(
                        font: UIFont(name: "Avenir Medium", size: 20)!,
                        color: textColor
                    ),
                    button: CourierStyles.Button(
                        font: CourierStyles.Font(
                            font: UIFont(name: "Avenir Black", size: 16)!,
                            color: .white
                        ),
                        backgroundColor: primaryColor,
                        cornerRadius: 100
                    )
                )
            ),
            darkTheme: CourierInboxTheme(
                brandId: Env.COURIER_BRAND_ID,
                unreadIndicatorStyle: CourierStyles.Inbox.UnreadIndicatorStyle(
                    indicator: .dot
                ),
                titleStyle: CourierStyles.Inbox.TextStyle(
                    unread: CourierStyles.Font(
                        font: UIFont(name: "Avenir Black", size: 20)!,
                        color: .white
                    ),
                    read: CourierStyles.Font(
                        font: UIFont(name: "Avenir Black", size: 20)!,
                        color: .gray
                    )
                ),
                timeStyle: CourierStyles.Inbox.TextStyle(
                    unread: CourierStyles.Font(
                        font: UIFont(name: "Avenir Medium", size: 16)!,
                        color: .white
                    ),
                    read: CourierStyles.Font(
                        font: UIFont(name: "Avenir Medium", size: 16)!,
                        color: .gray
                    )
                ),
                bodyStyle: CourierStyles.Inbox.TextStyle(
                    unread: CourierStyles.Font(
                        font: UIFont(name: "Avenir Medium", size: 18)!,
                        color: .white
                    ),
                    read: CourierStyles.Font(
                        font: UIFont(name: "Avenir Medium", size: 18)!,
                        color: .gray
                    )
                ),
                buttonStyle: CourierStyles.Inbox.ButtonStyle(
                    unread: CourierStyles.Button(
                        font: CourierStyles.Font(
                            font: UIFont(name: "Avenir Black", size: 16)!,
                            color: .white
                        ),
                        cornerRadius: 0
                    ),
                    read: CourierStyles.Button(
                        font: CourierStyles.Font(
                            font: UIFont(name: "Avenir Black", size: 16)!,
                            color: .white
                        ),
                        cornerRadius: 0
                    )
                ),
                cellStyle: CourierStyles.Cell(
                    separatorStyle: .none
                ),
                infoViewStyle: CourierStyles.Inbox.InfoViewStyle(
                    font: CourierStyles.Font(
                        font: UIFont(name: "Avenir Medium", size: 20)!,
                        color: .white
                    ),
                    button: CourierStyles.Button(
                        font: CourierStyles.Font(
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
        
    }

}
