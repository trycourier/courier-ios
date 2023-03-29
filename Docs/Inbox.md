- [Requirements](https://github.com/trycourier/courier-ios/tree/feature/inbox-docs#requirements)
- [Installation](https://github.com/trycourier/courier-ios/tree/feature/inbox-docs#installation)
- [Authentication](https://github.com/trycourier/courier-ios/blob/feature/inbox-docs/Docs/Authentication.md)
- [Inbox](https://github.com/trycourier/courier-ios/blob/feature/inbox-docs/Docs/Inbox.md)
- [Push Notifications](https://github.com/trycourier/courier-ios/blob/feature/inbox-docs/Docs/PushNotifications.md)
- [Testing](https://github.com/trycourier/courier-ios/blob/feature/inbox-docs/Docs/Testing.md)

# Inbox

```swift

// Prebuilt UI implementation

let font = CourierInboxFont(
    font: UIFont(name: "Avenir Medium", size: 18)!,
    color: UIColor.systemBlue
)

let inboxTheme = CourierInboxTheme(
    brandId: "AB123...",
    messageAnimationStyle: UITableView.RowAnimation.fade,
    unreadIndicatorBarColor: UIColor.systemBlue,
    loadingIndicatorColor: UIColor.systemBlue,
    titleFont: font,
    timeFont: font,
    bodyFont: font,
    detailTitleFont: font,
    buttonStyles: CourierInboxButtonStyles(
        font: font,
        backgroundColor: UIColor.systemBlue,
        cornerRadius: 100
    ),
    cellStyles: CourierInboxCellStyles(
        separatorStyle: .singleLine,
        separatorInsets: .zero
    )
)

let inboxView = CourierInbox(
    lightTheme: inboxTheme,
    darkTheme: inboxTheme,
    didClickInboxMessageAtIndex: { message, index in
        message.isRead ? message.markAsUnread() : message.markAsRead()
        print(index, message)
    },
    didClickInboxActionForMessageAtIndex: { action, message, index in
        print(action, message, index)
    },
    didScrollInbox: { scrollView in
        print(scrollView.contentOffset.y)
    }
)

// Custom implementation

let inboxListener = Courier.shared.addInboxListener(
    onInitialLoad: {
        print("Inbox listener is starting")
    },
    onError: { error in
        print(String(describing: error))
    },
    onMessagesChanged: { messages, unreadMessageCount, totalMessageCount, canPaginate in
        print(messages, unreadMessageCount, totalMessageCount, canPaginate)
    }
)

inboxListener.remove()
Courier.shared.removeAllInboxListeners()

Courier.shared.inboxPaginationLimit = 123
let inboxMessages = Courier.shared.inboxMessages

try await Courier.shared.fetchNextPageOfMessages()
try await Courier.shared.refreshInbox()
try await Courier.shared.readMessage(messageId: "1-321...")
try await Courier.shared.unreadMessage(messageId: "1-321...")
try await Courier.shared.readAllInboxMessages()
            
```
