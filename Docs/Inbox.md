// BANNER

# Courier Inbox

An in-app notification center list you can use to notify you users. Allows you to build user experiences like the Facebook notification feed very quickly.

&emsp;

⚠️ Courier Inbox requires [`Authentication`](https://github.com/trycourier/courier-ios/blob/feature/inbox-docs/Docs/Authentication.md) to view inbox messages that belong to a specific user.

&emsp;
                                     
# Usage

The following examples go over how to implement the `CourierInbox` View. This is a view that contains a list of messages you can show to your user.

&emsp;

## Default Example

![default-inbox-styles](https://user-images.githubusercontent.com/6370613/228880296-faeac9ee-60c6-4d66-968a-9205c0553f61.png)

This sample shows all default styles that come built in with Courier Inbox. All UI is rendered with native `UIKit` Views and supports system colors and dark mode.

```swift
import Courier_iOS

// Create the view
let courierInbox = CourierInbox(
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

// Add the view to your UI
courierInbox.translatesAutoresizingMaskIntoConstraints = false
view.addSubview(courierInbox)

// Constrain the view how you'd like
NSLayoutConstraint.activate([
    courierInbox.topAnchor.constraint(equalTo: view.topAnchor),
    courierInbox.bottomAnchor.constraint(equalTo: view.bottomAnchor),
    courierInbox.leadingAnchor.constraint(equalTo: view.leadingAnchor),
    courierInbox.trailingAnchor.constraint(equalTo: view.trailingAnchor),
])
```

&emsp;

## Styled Example

This sample shows all the available styles you can apply to the `CourierInbox` to customize the view quickly.

```swift
import Courier_iOS

// Theme object containing all the styles you want to apply 
let inboxTheme = CourierInboxTheme(
    messageAnimationStyle: .right,
    unreadIndicatorBarColor: .systemPurple,
    loadingIndicatorColor: .systemPink,
    titleFont: CourierInboxFont(
        font: UIFont(name: "Avenir Black", size: 20)!,
        color: .black
    ),
    timeFont: CourierInboxFont(
        font: UIFont(name: "Avenir Medium", size: 16)!,
        color: .black
    ),
    bodyFont: CourierInboxFont(
        font: UIFont(name: "Avenir Medium", size: 18)!,
        color: .black
    ),
    detailTitleFont: CourierInboxFont(
        font: UIFont(name: "Avenir Medium", size: 20)!,
        color: .black
    ),
    buttonStyles: CourierInboxButtonStyles(
        font: CourierInboxFont(
            font: UIFont(name: "Avenir Black", size: 16)!,
            color: .white
        ),
        backgroundColor: .systemPink,
        cornerRadius: 100 // 0 will be square & anything over 16 will be rounded
    ),
    cellStyles: CourierInboxCellStyles(
        separatorStyle: .singleLine,
        separatorInsets: .zero
    )
)

// Pass the theme to the inbox
// This example will use the same theme for light and dark mode
let courierInbox = CourierInbox(
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

view.addSubview(courierInbox)

...
```

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
