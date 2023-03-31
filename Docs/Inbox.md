<img width="1000" alt="inbox-banner" src="https://user-images.githubusercontent.com/6370613/228923687-afc608f1-90cd-4898-aae6-7c005dced39d.png">

&emsp;

# Courier Inbox

An in-app notification center list you can use to notify your users. Allows you to build high quality, flexible notification feeds very quickly.

## Requirements

<table>
    <thead>
        <tr>
            <th width="250px" align="left">Feature</th>
            <th width="750px" align="left">Reason</th>
        </tr>
    </thead>
    <tbody>
        <tr width="600px">
            <td align="left">
                <a href="https://github.com/trycourier/courier-ios/blob/feature/inbox-docs/Docs/Authentication.md">
                    <code>Authentication</code>
                </a>
            </td>
            <td align="left">
                Needs Authentication to view inbox messages that belong to a user.
            </td>
        </tr>
    </tbody>
</table>

&emsp;
                                     
# Usage

`CourierInbox` works with all native iOS UI frameworks.

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

## Default Inbox Example

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

## Styled Inbox Example

The styles you can use to quickly customize the `CourierInbox`.

<img width="415" alt="styled-inbox" src="https://user-images.githubusercontent.com/6370613/228883605-c8f5a63b-8be8-491d-9d19-ac2d2a666076.png">

```swift
import Courier_iOS

let textColor = UIColor(red: 42 / 255, green: 21 / 255, blue: 55 / 255, alpha: 100)
let primaryColor = UIColor(red: 136 / 255, green: 45 / 255, blue: 185 / 255, alpha: 100)
let secondaryColor = UIColor(red: 234 / 255, green: 104 / 255, blue: 102 / 255, alpha: 100)

// Theme object containing all the styles you want to apply 
let inboxTheme = CourierInboxTheme(
    messageAnimationStyle: .fade,
    unreadIndicatorBarColor: secondaryColor,
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

&emsp;

### Courier Studio Branding (Optional)

<img width="782" alt="setting" src="https://user-images.githubusercontent.com/6370613/228931428-04dc2130-789a-4ac3-bf3f-0bbb49d5519a.png">

You can control your branding from the [`Courier Studio`](https://app.courier.com/designer/brands). 

```swift 
let brandedThemeWithLoadingColorOverride = CourierInboxTheme(
    brandId: "YOUR_BRAND_ID",
    loadingIndicatorColor: .red, // ⚠️ Will override the brand primary color
    ...
)

let courierInbox = CourierInbox(
    lightTheme: brandedThemeWithLoadingColorOverride,
    ...
)
```

&emsp;

<table>
    <thead>
        <tr>
            <th width="800px" align="left">Supported Brand Styles</th>
            <th width="200px" align="center">Support</th>
        </tr>
    </thead>
    <tbody>
        <tr width="600px">
            <td align="left"><code>Primary Color</code></td>
            <td align="center">✅</td>
        </tr>
        <tr width="600px">
            <td align="left"><code>Show/Hide Courier Footer</code></td>
            <td align="center">✅</td>
        </tr>
    </tbody>
</table>

&emsp;

## Custom Inbox Example

The raw data you can use to build whatever UI you'd like.

<img width="415" alt="custom-inbox" src="https://user-images.githubusercontent.com/6370613/228886933-d6f1ef6a-c582-4269-af68-da988aa25063.png">

```swift
import UIKit
import Courier_iOS

class CustomInboxViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    private var inboxListener: CourierInboxListener? = nil
    
    ...

    override func viewDidLoad() {
        super.viewDidLoad()
        
        ...
        
        // Allows you to listen to all inbox changes and build whatever you'd like
        self.inboxListener = Courier.shared.addInboxListener(
            onInitialLoad: {
                ...
            },
            onError: { error in
                ...
            },
            onMessagesChanged: { messages, unreadMessageCount, totalMessageCount, canPaginate in
                ...
                self.collectionView.reloadData()
            }
        )
        
    }
    
    ...
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CustomInboxCollectionViewCell.id, for: indexPath as IndexPath) as! CustomInboxCollectionViewCell
        
        let message = inboxMessages[indexPath.row]
        cell.setMessage(message)
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let message = inboxMessages[indexPath.row].toJson()
        message.isRead ? message.markAsUnread() : message.markAsRead()
    }
    
    deinit {
        self.inboxListener?.remove()
    }

}
...
```

&emsp;

## Full Examples

<table>
    <thead>
        <tr>
            <th width="800px" align="left">Link</th>
            <th width="200px" align="center">Style</th>
        </tr>
    </thead>
    <tbody>
        <tr width="600px">
            <td align="left">
                <a href="https://github.com/trycourier/courier-ios/blob/feature/inbox-docs/Example/Example/PrebuiltInboxViewController.swift">
                    <code>Default Example</code>
                </a>
            </td>
            <td align="center">
                <a href="https://github.com/trycourier/courier-ios/blob/feature/inbox-docs/Docs/Inbox.md#default-inbox-example">
                    <code>Default</code>
                </a>
            </td>
        </tr>
        <tr width="600px">
            <td align="left">
                <a href="https://github.com/trycourier/courier-ios/blob/feature/inbox-docs/Example/Example/StyledInboxViewController.swift">
                    <code>Styled Example</code>
                </a>
            </td>
            <td align="center">
                <a href="https://github.com/trycourier/courier-ios/blob/feature/inbox-docs/Docs/Inbox.md#styled-inbox-example">
                    <code>Styled</code>
                </a>
            </td>
        </tr>
        <tr width="600px">
            <td align="left">
                <a href="https://github.com/trycourier/courier-ios/blob/feature/inbox-docs/Example/Example/CustomInboxViewController.swift">
                    <code>Custom Example</code>
                </a>
            </td>
            <td align="center">
                <a href="https://github.com/trycourier/courier-ios/blob/feature/inbox-docs/Docs/Inbox.md#custom-inbox-example">
                    <code>Custom</code>
                </a>
            </td>
        </tr>
        <tr width="600px">
            <td align="left">
                <a href="https://github.com/trycourier/courier-ios/blob/feature/inbox-docs/SwiftUI-Example/SwiftUI-Example/ContentView.swift">
                    <code>SwiftUI Example</code>
                </a>
            </td>
            <td align="center">
                <a href="https://github.com/trycourier/courier-ios/blob/feature/inbox-docs/Docs/Inbox.md#styled-inbox-example">
                    <code>Styled</code>
                </a>
            </td>
        </tr>
    </tbody>
</table>

&emsp;

## Available Properties and Functions 

```swift
import Courier_iOS

// Listen to all inbox events
// Only one "pipe" of data is created behind the scenes for network / performance reasons
let inboxListener = Courier.shared.addInboxListener(
    onInitialLoad: {
        // Called when the inbox starts up
    },
    onError: { error in
        // Called if an error occurs
    },
    onMessagesChanged: { messages, unreadMessageCount, totalMessageCount, canPaginate in
        // Called when messages update
    }
)

// Stop the current listener
inboxListener.remove()

// Remove all listeners
// This will also remove the listener of the prebuilt UI
Courier.shared.removeAllInboxListeners()

// The amount of inbox messages to fetch at a time
// Will affect prebuilt UI
Courier.shared.inboxPaginationLimit = 123

// The available messages the inbox has
let inboxMessages = Courier.shared.inboxMessages

Task {

    // Fetches the next page of messages
    try await Courier.shared.fetchNextPageOfMessages()

    // Reloads the inbox
    // Commonly used with pull to refresh
    try await Courier.shared.refreshInbox()

    // Reads / Unreads a message
    // Writes the update instantly and performs request in background
    try await Courier.shared.readMessage(messageId: "1-321...")
    try await Courier.shared.unreadMessage(messageId: "1-321...")

    // Reads all the messages
    // Writes the update instantly and performs request in background
    try await Courier.shared.readAllInboxMessages()

}

// Mark message as read/unread
let message = InboxMessage(...)

// Calls Courier.shared.un/readMessage(messageId...) under the hood
// Has optional callbacks
message.markAsRead()
message.markAsUnread()

```
