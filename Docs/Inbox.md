// BANNER

# Courier Inbox

An in-app notification center list you can use to notify you users. Allows you to build user experiences like the Facebook notification feed very quickly.

⚠️ Courier Inbox requires [`Authentication`](https://github.com/trycourier/courier-ios/blob/feature/inbox-docs/Docs/Authentication.md) to view inbox messages that belong to a specific user.

&emsp;
                                     
# Usage

`CourierInbox` works with all native UI frameworks.

<table>
    <thead>
        <tr>
            <th width="800px" align="left">UI Framework</th>
            <th width="200px" align="center">Support</th>
        </tr>
    </thead>
    <tbody>
        <tr width="600px">
            <td align="left"><code>UIKit</code></td>
            <td align="center">✅</td>
        </tr>
        <tr width="600px">
            <td align="left"><code>XIB</code></td>
            <td align="center">⚠️ Not optimised</td>
        </tr>
        <tr width="600px">
            <td align="left"><code>SwiftUI</code></td>
            <td align="center">✅</td>
        </tr>
    </tbody>
</table>

&emsp;

## Default Example

The default `CourierInbox` styles.

<img width="810" alt="default-inbox-styles" src="https://user-images.githubusercontent.com/6370613/228881237-97534448-e8af-46e4-91de-d3423e95dc14.png">

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

The styles you can use to quickly customize the `CourierInbox`.

<img width="415" alt="styled-inbox" src="https://user-images.githubusercontent.com/6370613/228883605-c8f5a63b-8be8-491d-9d19-ac2d2a666076.png">

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
