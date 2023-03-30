// BANNER

# Courier Inbox

An in-app notification center list you can use to notify you users. Allows you to build user experiences similar to the Facebook notification feed very quickly.

⚠️ `CourierInbox` requires [`Authentication`](https://github.com/trycourier/courier-ios/blob/feature/inbox-docs/Docs/Authentication.md) to view inbox messages that belong to a specific user.

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

The default `CourierInbox` styles. [`Full Example`](https://github.com/trycourier/courier-ios/blob/feature/inbox-docs/Example/Example/PrebuiltInboxViewController.swift)

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

The styles you can use to quickly customize the `CourierInbox`. [`Full Example`](https://github.com/trycourier/courier-ios/blob/feature/inbox-docs/Example/Example/PrebuiltInboxViewController.swift)

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

## Custom Example

The raw data you have to build any UI you'd like. This example is using a `UICollectionView`. [`Full Example`](https://github.com/trycourier/courier-ios/blob/feature/inbox-docs/Example/Example/CustomInboxViewController.swift)

<img width="415" alt="custom-inbox" src="https://user-images.githubusercontent.com/6370613/228886933-d6f1ef6a-c582-4269-af68-da988aa25063.png">

```swift
import UIKit
import Courier_iOS

class CustomInboxViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    ...

    override func viewDidLoad() {
        super.viewDidLoad()
        
        ...
        
        self.inboxListener = Courier.shared.addInboxListener(
            onInitialLoad: {
                self.setState(.loading)
            },
            onError: { error in
                self.setState(.error, error: String(describing: error))
            },
            onMessagesChanged: { messages, unreadMessageCount, totalMessageCount, canPaginate in
                ...
                self.collectionView.reloadData()
            }
        )
        
    }
    
    @objc private func onPullRefresh() {
        Task {
            try await Courier.shared.refreshInbox()
            self.collectionView.refreshControl?.endRefreshing()
        }
    }
      
    @objc private func readAll() {
        Courier.shared.readAllInboxMessages()
    }
    
    private func setState(_ state: State, error: String? = nil) {
        ...
    }
    
    ...
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CustomInboxCollectionViewCell.id, for: indexPath as IndexPath) as! CustomInboxCollectionViewCell
        
        if (indexPath.section == 0) {
            let message = inboxMessages[indexPath.row]
            cell.setMessage(message)
        } else {
            cell.showLoading()
        }
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if (indexPath.section == 1) {
            Courier.shared.fetchNextPageOfMessages()
        }
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

<!--// Prebuilt UI implementation-->
<!---->
<!--let font = CourierInboxFont(-->
<!--    font: UIFont(name: "Avenir Medium", size: 18)!,-->
<!--    color: UIColor.systemBlue-->
<!--)-->
<!---->
<!--let inboxTheme = CourierInboxTheme(-->
<!--    brandId: "AB123...",-->
<!--    messageAnimationStyle: UITableView.RowAnimation.fade,-->
<!--    unreadIndicatorBarColor: UIColor.systemBlue,-->
<!--    loadingIndicatorColor: UIColor.systemBlue,-->
<!--    titleFont: font,-->
<!--    timeFont: font,-->
<!--    bodyFont: font,-->
<!--    detailTitleFont: font,-->
<!--    buttonStyles: CourierInboxButtonStyles(-->
<!--        font: font,-->
<!--        backgroundColor: UIColor.systemBlue,-->
<!--        cornerRadius: 100-->
<!--    ),-->
<!--    cellStyles: CourierInboxCellStyles(-->
<!--        separatorStyle: .singleLine,-->
<!--        separatorInsets: .zero-->
<!--    )-->
<!--)-->
<!---->
<!--let inboxView = CourierInbox(-->
<!--    lightTheme: inboxTheme,-->
<!--    darkTheme: inboxTheme,-->
<!--    didClickInboxMessageAtIndex: { message, index in-->
<!--        message.isRead ? message.markAsUnread() : message.markAsRead()-->
<!--        print(index, message)-->
<!--    },-->
<!--    didClickInboxActionForMessageAtIndex: { action, message, index in-->
<!--        print(action, message, index)-->
<!--    },-->
<!--    didScrollInbox: { scrollView in-->
<!--        print(scrollView.contentOffset.y)-->
<!--    }-->
<!--)-->
<!---->
<!--// Custom implementation-->
<!---->
<!--let inboxListener = Courier.shared.addInboxListener(-->
<!--    onInitialLoad: {-->
<!--        print("Inbox listener is starting")-->
<!--    },-->
<!--    onError: { error in-->
<!--        print(String(describing: error))-->
<!--    },-->
<!--    onMessagesChanged: { messages, unreadMessageCount, totalMessageCount, canPaginate in-->
<!--        print(messages, unreadMessageCount, totalMessageCount, canPaginate)-->
<!--    }-->
<!--)-->
<!---->
<!--inboxListener.remove()-->
<!--Courier.shared.removeAllInboxListeners()-->
<!---->
<!--Courier.shared.inboxPaginationLimit = 123-->
<!--let inboxMessages = Courier.shared.inboxMessages-->
<!---->
<!--try await Courier.shared.fetchNextPageOfMessages()-->
<!--try await Courier.shared.refreshInbox()-->
<!--try await Courier.shared.readMessage(messageId: "1-321...")-->
<!--try await Courier.shared.unreadMessage(messageId: "1-321...")-->
<!--try await Courier.shared.readAllInboxMessages()-->
<!--            -->
<!--```-->
