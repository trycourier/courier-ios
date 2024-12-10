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

## JWT Authentication

If you are using JWT authentication, be sure to enable JWT support on the Courier Inbox Provider [`here`](https://app.courier.com/integrations/catalog/courier).

<img width="385" alt="Screenshot 2024-12-09 at 11 19 31 AM" src="https://github.com/user-attachments/assets/71c945f3-9fa0-4736-ae0d-a4760cb49220">
                
## Usage

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

<img width="390" alt="default-inbox-styles" src="https://github.com/user-attachments/assets/23830e36-9bef-4dda-9f2c-d2eddb866055">

&emsp;

### SwiftUI

```swift
import Courier_iOS
CourierInboxView(
    didClickInboxMessageAtIndex: { message, index in
        message.isRead ? message.markAsUnread() : message.markAsRead()
        print(index, message)
    },
    didLongPressInboxMessageAtIndex: { message, index in
        message.markAsArchived()
        print(index, message)
    },
    didClickInboxActionForMessageAtIndex: { action, message, index in
        print(action, message, index)
    },
    didScrollInbox: { scrollView in
        print(scrollView.contentOffset.y)
    }
)
```

### UIKit

```swift
let courierInbox = CourierInbox(
    didClickInboxMessageAtIndex: { message, index in
        message.isRead ? message.markAsUnread() : message.markAsRead()
        print(index, message)
    },
    didLongPressInboxMessageAtIndex: { message, index in
        message.markAsArchived()
        print(index, message)
    },
    didClickInboxActionForMessageAtIndex: { action, message, index in
        print(action, message, index)
    },
    didScrollInbox: { scrollView in
        print(scrollView.contentOffset.y)
    }
)
```

&emsp;

## Styled Inbox Example

The styles you can use to quickly customize the `CourierInbox`.

<img width="390" alt="styled-inbox-styles" src="https://github.com/user-attachments/assets/27cd25e1-c290-4671-b486-69502b683a30">

&emsp;

```swift
func getTheme() -> CourierInboxTheme {
    let whiteColor = UIColor.white
    let blackColor = UIColor.black
    let blackLightColor = UIColor.black.withAlphaComponent(0.5)
    let primaryColor = UIColor(red: 102/255, green: 80/255, blue: 164/255, alpha: 1)
    let primaryLightColor = UIColor(red: 98/255, green: 91/255, blue: 113/255, alpha: 1)
    let font = UIFont(name: "Avenir-Medium", size: 18)

    return CourierInboxTheme(
        tabIndicatorColor: primaryColor,
        tabStyle: CourierStyles.Inbox.TabStyle(
            selected: CourierStyles.Inbox.TabItemStyle(
                font: CourierStyles.Font(
                    font: font!,
                    color: primaryColor
                ),
                indicator: CourierStyles.Inbox.TabIndicatorStyle(
                    font: CourierStyles.Font(
                        font: font!,
                        color: whiteColor
                    ),
                    color: primaryColor
                )
            ),
            unselected: CourierStyles.Inbox.TabItemStyle(
                font: CourierStyles.Font(
                    font: font!,
                    color: blackLightColor
                ),
                indicator: CourierStyles.Inbox.TabIndicatorStyle(
                    font: CourierStyles.Font(
                        font: font!,
                        color: whiteColor
                    ),
                    color: blackLightColor
                )
            )
        ),
        readingSwipeActionStyle: CourierStyles.Inbox.ReadingSwipeActionStyle(
            read: CourierStyles.Inbox.SwipeActionStyle(
                icon: UIImage(systemName: "envelope.open.fill"),
                color: primaryColor
            ),
            unread: CourierStyles.Inbox.SwipeActionStyle(
                icon: UIImage(systemName: "envelope.fill"),
                color: primaryLightColor
            )
        ),
        archivingSwipeActionStyle: CourierStyles.Inbox.ArchivingSwipeActionStyle(
            archive: CourierStyles.Inbox.SwipeActionStyle(
                icon: UIImage(systemName: "archivebox.fill"),
                color: primaryColor
            )
        ),
        unreadIndicatorStyle: CourierStyles.Inbox.UnreadIndicatorStyle(
            indicator: .dot,
            color: primaryColor
        ),
        titleStyle: CourierStyles.Inbox.TextStyle(
            unread: CourierStyles.Font(
                font: font!,
                color: blackColor
            ),
            read: CourierStyles.Font(
                font: font!,
                color: blackColor
            )
        ),
        timeStyle: CourierStyles.Inbox.TextStyle(
            unread: CourierStyles.Font(
                font: font!,
                color: blackColor
            ),
            read: CourierStyles.Font(
                font: font!,
                color: blackColor
            )
        ),
        bodyStyle: CourierStyles.Inbox.TextStyle(
            unread: CourierStyles.Font(
                font: font!,
                color: blackLightColor
            ),
            read: CourierStyles.Font(
                font: font!,
                color: blackLightColor
            )
        ),
        buttonStyle: CourierStyles.Inbox.ButtonStyle(
            unread: CourierStyles.Button(
                font: CourierStyles.Font(
                    font: font!,
                    color: whiteColor
                ),
                backgroundColor: primaryColor,
                cornerRadius: 100
            ),
            read: CourierStyles.Button(
                font: CourierStyles.Font(
                    font: font!,
                    color: whiteColor
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
                font: font!,
                color: blackColor
            ),
            button: CourierStyles.Button(
                font: CourierStyles.Font(
                    font: font!,
                    color: whiteColor
                ),
                backgroundColor: primaryColor,
                cornerRadius: 100
            )
        )
    )
}
```

### SwiftUI

```swift
import Courier_iOS
CourierInboxView(
    canSwipePages: true,
    lightTheme: getTheme(),
    darkTheme: getTheme(),
    ..
)
```

```swift
import Courier_iOS
let courierInbox = CourierInbox(
    canSwipePages: true,
    lightTheme: inboxTheme,
    darkTheme: inboxTheme,
    ..
)
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

```swift
import UIKit
import Courier_iOS

class CustomInboxViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    private var inboxListener: CourierInboxListener? = nil
    
    ..

    override func viewDidLoad() {
        super.viewDidLoad()
        
        ..
        
        // Allows you to listen to all inbox changes and build whatever you'd like
        self.inboxListener = Courier.shared.addInboxListener(
            onLoading: { [weak self] in
                // Called when listener is registered, refreshing or restarting
            },
            onError: { [weak self] error in
                // Called on error or sign out
            },
            onUnreadCountChanged: { [weak self] count in
                // Will return 0 when a user is signed out
            },
            onFeedChanged: { [weak self] set in
                // Called when the feed initially loads or is restarted from scratch
            },
            onArchiveChanged: { [weak self] set in
                // Called when the archive initially loads or is restarted from scratch
            },
            onPageAdded: { [weak self] feed, set in
                // Called when pagination happens
            },
            onMessageChanged: { [weak self] feed, index, message in
                // Called when a message is change (i.e. read / unread)
            },
            onMessageAdded: { [weak self] feed, index, message in
                // Called when a message is added (i.e. new message received in realtime)
            },
            onMessageRemoved: { [weak self] feed, index, message in
                // Called when a message is removed (i.e. message is archived)
            }
        )
        
    }
    
    deinit {
        self.inboxListener?.remove()
    }

}
```

&emsp;

## Available Properties and Functions 

```swift
import Courier_iOS

// Listen to all inbox events
// Only one "pipe" of data is created behind the scenes for network / performance reasons
let inboxListener = Courier.shared.addInboxListener(
    onLoading: { [weak self] in
        // Called when listener is registered, refreshing or restarting
    },
    onError: { [weak self] error in
        // Called on error or sign out
    },
    onUnreadCountChanged: { [weak self] count in
        // Will return 0 when a user is signed out
    },
    onFeedChanged: { [weak self] set in
        // Called when the feed initially loads or is restarted from scratch
    },
    onArchiveChanged: { [weak self] set in
        // Called when the archive initially loads or is restarted from scratch
    },
    onPageAdded: { [weak self] feed, set in
        // Called when pagination happens
    },
    onMessageChanged: { [weak self] feed, index, message in
        // Called when a message is change (i.e. read / unread)
    },
    onMessageAdded: { [weak self] feed, index, message in
        // Called when a message is added (i.e. new message received in realtime)
    },
    onMessageRemoved: { [weak self] feed, index, message in
        // Called when a message is removed (i.e. message is archived)
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
