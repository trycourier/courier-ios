//
//  StyledInboxViewController.swift
//  Example
//
//  Created by https://github.com/mikemilla on 3/14/23.
//

import UIKit
import Courier_iOS

class StyledInboxViewController: UIViewController {
    
    private lazy var courierInbox = {
        return CourierInbox(
            canSwipePages: true,
            lightTheme: makeTheme(.light),
            darkTheme: makeTheme(.dark),
            didClickInboxMessageAtIndex: { message, index in
                if message.isArchived { return }
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
                self.showCode(title: "Inbox Action Click", code: action.toJson() ?? "")
            },
            didScrollInbox: { scrollView in
                print(scrollView.contentOffset.y)
            }
        )
    }()

    private func makeTheme(_ palette: StyledPalette) -> CourierInboxTheme {
        return CourierInboxTheme(
            brandId: Env.COURIER_BRAND_ID,
            backgroundColor: palette.surface,
            tabBackgroundColor: palette.surface,
            listItemBackgroundColor: palette.surface,
            tabIndicatorColor: palette.accent,
            tabStyle: CourierStyles.Inbox.TabStyle(
                selected: CourierStyles.Inbox.TabItemStyle(
                    font: CourierStyles.Font(font: StyledFont.black(17), color: palette.text),
                    indicator: CourierStyles.Inbox.TabIndicatorStyle(
                        font: CourierStyles.Font(font: StyledFont.black(13), color: palette.onAccent),
                        color: palette.accent
                    )
                ),
                unselected: CourierStyles.Inbox.TabItemStyle(
                    font: CourierStyles.Font(font: StyledFont.medium(17), color: palette.secondaryText),
                    indicator: CourierStyles.Inbox.TabIndicatorStyle(
                        font: CourierStyles.Font(font: StyledFont.heavy(13), color: palette.accent),
                        color: palette.accentSoft
                    )
                )
            ),
            readingSwipeActionStyle: CourierStyles.Inbox.ReadingSwipeActionStyle(
                read: CourierStyles.Inbox.SwipeActionStyle(
                    icon: UIImage(systemName: "envelope.open.fill"),
                    color: palette.secondaryText
                ),
                unread: CourierStyles.Inbox.SwipeActionStyle(
                    icon: UIImage(systemName: "envelope.fill"),
                    color: palette.accent
                )
            ),
            archivingSwipeActionStyle: CourierStyles.Inbox.ArchivingSwipeActionStyle(
                archive: CourierStyles.Inbox.SwipeActionStyle(
                    icon: UIImage(systemName: "archivebox.fill"),
                    color: palette.archive
                )
            ),
            messageAnimationStyle: .fade,
            unreadIndicatorStyle: CourierStyles.Inbox.UnreadIndicatorStyle(
                indicator: .dot,
                color: palette.accent
            ),
            titleStyle: CourierStyles.Inbox.TextStyle(
                unread: CourierStyles.Font(font: StyledFont.black(17), color: palette.text),
                read: CourierStyles.Font(font: StyledFont.heavy(17), color: palette.secondaryText)
            ),
            timeStyle: CourierStyles.Inbox.TextStyle(
                unread: CourierStyles.Font(font: StyledFont.heavy(14), color: palette.accent),
                read: CourierStyles.Font(font: StyledFont.medium(14), color: palette.secondaryText)
            ),
            bodyStyle: CourierStyles.Inbox.TextStyle(
                unread: CourierStyles.Font(font: StyledFont.medium(16), color: palette.text),
                read: CourierStyles.Font(font: StyledFont.medium(16), color: palette.secondaryText)
            ),
            buttonStyle: CourierStyles.Inbox.ButtonStyle(
                unread: CourierStyles.Button(
                    font: CourierStyles.Font(font: StyledFont.heavy(15), color: palette.onAccent),
                    backgroundColor: palette.accent,
                    cornerRadius: 100
                ),
                read: CourierStyles.Button(
                    font: CourierStyles.Font(font: StyledFont.heavy(15), color: palette.accent),
                    backgroundColor: palette.accentSoft,
                    cornerRadius: 100
                )
            ),
            cellStyle: CourierStyles.Cell(
                separatorStyle: .singleLine,
                separatorColor: palette.separator
            ),
            infoViewStyle: CourierStyles.InfoViewStyle(
                font: CourierStyles.Font(font: StyledFont.medium(18), color: palette.secondaryText),
                button: CourierStyles.Button(
                    font: CourierStyles.Font(font: StyledFont.heavy(15), color: palette.onAccent),
                    backgroundColor: palette.accent,
                    cornerRadius: 100
                )
            )
        )
    }

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
