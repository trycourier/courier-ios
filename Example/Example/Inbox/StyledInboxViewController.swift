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
            canSwipePages: true,
            lightTheme: CourierInboxTheme(
                tabIndicatorColor: primaryColor,
                tabStyle: CourierStyles.Inbox.TabStyle(
                    selected: CourierStyles.Inbox.TabItemStyle(
                        font: CourierStyles.Font(
                            font: UIFont(name: "Avenir Black", size: 18)!,
                            color: textColor
                        ),
                        indicator: CourierStyles.Inbox.TabIndicatorStyle(
                            font: CourierStyles.Font(
                                font: UIFont(name: "Avenir Black", size: 14)!,
                                color: .white
                            ),
                            color: primaryColor
                        )
                    ),
                    unselected: CourierStyles.Inbox.TabItemStyle(
                        font: CourierStyles.Font(
                            font: UIFont(name: "Avenir Medium", size: 18)!,
                            color: textColor
                        ),
                        indicator: CourierStyles.Inbox.TabIndicatorStyle(
                            font: CourierStyles.Font(
                                font: UIFont(name: "Avenir Medium", size: 14)!,
                                color: .white
                            ),
                            color: primaryColor
                        )
                    )
                ),
                readingSwipeActionStyle: CourierStyles.Inbox.ReadingSwipeActionStyle(
                    read: CourierStyles.Inbox.SwipeActionStyle(
                        icon: UIImage(systemName: "envelope.open.fill"),
                        color: .systemGray
                    ),
                    unread: CourierStyles.Inbox.SwipeActionStyle(
                        icon: UIImage(systemName: "envelope.fill"),
                        color: primaryColor
                    )
                ),
                archivingSwipeActionStyle: CourierStyles.Inbox.ArchivingSwipeActionStyle(
                    archive: CourierStyles.Inbox.SwipeActionStyle(
                        icon: UIImage(systemName: "archivebox.fill"),
                        color: secondaryColor
                    )
                ),
                messageAnimationStyle: .fade,
                unreadIndicatorStyle: CourierStyles.Inbox.UnreadIndicatorStyle(
                    indicator: .dot,
                    color: primaryColor
                ),
                titleStyle: CourierStyles.Inbox.TextStyle(
                    unread: CourierStyles.Font(
                        font: UIFont(name: "Avenir Black", size: 18)!,
                        color: textColor
                    ),
                    read: CourierStyles.Font(
                        font: UIFont(name: "Avenir Black", size: 18)!,
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
                infoViewStyle: CourierStyles.InfoViewStyle(
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
                tabStyle: CourierStyles.Inbox.TabStyle(
                    selected: CourierStyles.Inbox.TabItemStyle(
                        font: CourierStyles.Font(
                            font: UIFont(name: "Avenir Black", size: 18)!,
                            color: .white
                        ),
                        indicator: CourierStyles.Inbox.TabIndicatorStyle(
                            font: CourierStyles.Font(
                                font: UIFont(name: "Avenir Medium", size: 14)!,
                                color: .white
                            ),
                            color: nil
                        )
                    ),
                    unselected: CourierStyles.Inbox.TabItemStyle(
                        font: CourierStyles.Font(
                            font: UIFont(name: "Avenir Medium", size: 18)!,
                            color: .white
                        ),
                        indicator: CourierStyles.Inbox.TabIndicatorStyle(
                            font: CourierStyles.Font(
                                font: UIFont(name: "Avenir Medium", size: 14)!,
                                color: .white
                            ),
                            color: nil
                        )
                    )
                ),
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
                infoViewStyle: CourierStyles.InfoViewStyle(
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
                Task {
                    do {
                        message.isRead ? try await message.markAsUnread() : try await message.markAsRead()
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            },
            didLongPressInboxMessageAtIndex: { message, index in
                self.showActionSheet(message: message)
            },
            didClickInboxActionForMessageAtIndex: { action, message, index in
                self.showCodeAlert(title: "Inbox Action Click", code: action.toJson() ?? "")
            },
            didScrollInbox: { scrollView in
                print(scrollView.contentOffset.y)
            }
        )
    }()
    
    @objc private func readAllClick() {
        Task {
            do {
                try await Courier.shared.readAllInboxMessages()
            } catch {
                await Courier.shared.client?.log(error.localizedDescription)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Styled"

        courierInbox.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(courierInbox)
        
        NSLayoutConstraint.activate([
            courierInbox.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            courierInbox.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            courierInbox.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            courierInbox.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        
        let readAllButton = UIBarButtonItem(title: "Read All", style: .plain, target: self, action: #selector(readAllClick))
        navigationItem.rightBarButtonItem = readAllButton
        
    }

}
