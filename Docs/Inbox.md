<img width="1000" alt="inbox-banner" src="https://user-images.githubusercontent.com/6370613/232106969-a9b31065-0b81-4013-9e03-1f2d3b634ab7.png">

&emsp;

# Courier Inbox

An in-app notification center list you can use to notify your users. Allows you to build high quality, flexible notification feeds very quickly.

## Requirements

<table>
    <thead>
        <tr>
            <th width="250px" align="left">Requirement</th>
            <th width="800px" align="left">Reason</th>
        </tr>
    </thead>
    <tbody>
        <tr width="600px">
            <tr width="600px">
                <td align="left">
                    <a href="https://app.courier.com/channels/courier">
                        <code>Courier Inbox Provider</code>
                    </a>
                </td>
                <td align="left">
                    Needed to link your Courier Inbox to the SDK
                </td>
            </tr>
            <td align="left">
                <a href="https://github.com/trycourier/courier-ios/blob/master/Docs/Authentication.md">
                    <code>Authentication</code>
                </a>
            </td>
            <td align="left">
                Needed to view inbox messages that belong to a user.
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
            <th width="850px" align="left">UI Framework</th>
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

// UIKit

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

// SwiftUI

var body: some View {
    CourierInboxView(
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
}

```

&emsp;

## Styled Inbox Example

The styles you can use to quickly customize the `CourierInbox`.

<img width="431" alt="styled-inbox-styles" src="https://github.com/trycourier/courier-ios/assets/6370613/8170115f-7384-45d1-891c-dc7501db3827">

```swift
import Courier_iOS

let textColor = UIColor(red: 42 / 255, green: 21 / 255, blue: 55 / 255, alpha: 100)
let primaryColor = UIColor(red: 136 / 255, green: 45 / 255, blue: 185 / 255, alpha: 100)
let secondaryColor = UIColor(red: 234 / 255, green: 104 / 255, blue: 102 / 255, alpha: 100)

// Theme object containing all the styles you want to apply 
let inboxTheme = CourierInboxTheme(
    brandId: "7S9R...3Q1M", // Optional. Theme colors will override this brand.
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
)

// UIKit

// Pass the theme to the view
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

// SwiftUI

var body: some View {
    CourierInboxView(
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
}
```

&emsp;

### Courier Studio Branding (Optional)

<img width="782" alt="setting" src="https://user-images.githubusercontent.com/6370613/228931428-04dc2130-789a-4ac3-bf3f-0bbb49d5519a.png">

You can control your branding from the [`Courier Studio`](https://app.courier.com/designer/brands).

<table>
    <thead>
        <tr>
            <th width="850px" align="left">Supported Brand Styles</th>
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

---

👋 `Branding APIs` can be found <a href="https://github.com/trycourier/courier-ios/blob/master/Docs/Client.md#branding-apis"><code>here</code></a>

&emsp;

## Custom Inbox Example

The raw data you can use to build whatever UI you'd like.

<img width="415" alt="custom-inbox" src="https://github.com/trycourier/courier-ios/assets/6370613/1a818973-8ada-4e30-84b6-7f5da75fc800">

```swift
import UIKit
import Courier_iOS

class CustomInboxViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    private var messages: [InboxMessage] = []
    private var inboxListener: CourierInboxListener? = nil
    
    ...

    override func viewDidLoad() {
        super.viewDidLoad()
        
        ...
        
        // Allows you to listen to all inbox changes and build whatever you'd like
        self.inboxListener = Courier.shared.addInboxListener(
            onFeedChanged: { [weak self] set in
                self.messages = set.messages
                self.tableView.reloadData()
            }
        )
        
    }
    
    ...

    private var messages: [InboxMessage] {
        get {
            return Courier.shared.inboxMessages ?? []
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let message = messages[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: YourCustomTableViewCell.id, for: indexPath) as! YourCustomTableViewCell
        cell.message = message
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let message = messages[indexPath.row]
        
        message.isRead ? message.markAsUnread() : message.markAsRead()
        
    }
    
    deinit {
        self.inboxListener?.remove()
    }

}
...
```

&emsp;

## Available Properties and Functions 

```swift
import Courier_iOS

// Listen to all inbox events
// Only one "pipe" of data is created behind the scenes for network / performance reasons
let inboxListener = Courier.shared.addInboxListener(
    onLoading: { [weak self] in
        // Called when loading happened, usually at launch
    },
    onError: { [weak self] error in
        // Called when an error is received
    },
    onUnreadCountChanged: { [weak self] count in
        // Called when the total unread count changes
    },
    onFeedChanged: { [weak self] set in
        // Called when the inbox of feed messages changes
    },
    onArchiveChanged: { [weak self] set in
        // Called when the inbox of archived messages changes
    },
    onPageAdded: { [weak self] feed, set in
        // Called when a list of messages is fetched (i.e. pagination)
    },
    onMessageChanged: { [weak self] feed, index, message in
        // Called when a message is updated (i.e. a new message is read or unread)
    },
    onMessageAdded: { [weak self] feed, index, message in
        // Called when a message is added (i.e. a new message is received)
    },
    onMessageRemoved: { [weak self] feed, index, message in
        // Called when a message is removed (i.e. a message is archived)
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

Task {

    // The available messages the inbox has
    let inboxMessages = await Courier.shared.inboxMessages
    let archivedMessages = await Courier.shared.archivedMessages

    // Fetches the next page of messages
    try await Courier.shared.fetchNextInboxPage(.feed || .archived)

    // Reloads the inbox
    // Commonly used with pull to refresh
    try await Courier.shared.refreshInbox()

    // Handle events
    try await Courier.shared.readMessage("...")
    try await Courier.shared.unreadMessage("...")
    try await Courier.shared.openMessage("...")
    try await Courier.shared.clickMessage("...")
    try await Courier.shared.archiveMessage("...")

    // Reads all the messages
    // Writes the update instantly and performs request in background
    try await Courier.shared.readAllInboxMessages()

}

// Mark message as read/unread
let message = InboxMessage(...)

// Calls Courier.shared... under the hood
message.markAsRead()
message.markAsUnread()
message.markAsOpened()
message.markAsClicked()
message.markAsArchived()
```

---

👋 `Inbox APIs` can be found <a href="https://github.com/trycourier/courier-ios/blob/master/Docs/Client.md#inbox-apis"><code>here</code></a>
