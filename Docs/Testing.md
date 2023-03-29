- [Requirements](https://github.com/trycourier/courier-ios/tree/feature/inbox-docs#requirements)
- [Installation](https://github.com/trycourier/courier-ios/tree/feature/inbox-docs#installation)
- [Authentication](https://github.com/trycourier/courier-ios/blob/feature/inbox-docs/Docs/Authentication.md)
- [Inbox](https://github.com/trycourier/courier-ios/blob/feature/inbox-docs/Docs/Inbox.md)
- [Push Notifications](https://github.com/trycourier/courier-ios/blob/feature/inbox-docs/Docs/PushNotifications.md)
- [Testing](https://github.com/trycourier/courier-ios/blob/feature/inbox-docs/Docs/Testing.md)

# Testing

```swift

let messageId = try await Courier.shared.sendPush(
    authKey: "pk_prod_H12...",
    userId: "example_user_id",
    title: "Hey! 👋",
    body: "Courier is awesome!!",
    providers: [.apns, .fcm, .inbox],
)

```

## **5. Testing Push Notifications**

> If you don't need push notification support, you can skip this step.

Courier allows you to send a push notification directly from the SDK to a user id. No token juggling or backend needed!

```swift
class YourViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Task {
        
            let notificationPermission = await Courier.shared.getNotificationPermissionStatus()
            print(notificationPermission)

            // Notification permissions must be `.authorized` to receive pushes
            let requestedNotificationPermission = await Courier.shared.requestNotificationPermission()
            print(requestedNotificationPermission)
            
            sendTestPush()
        
        }
        
    }
    
    private func sendTestPush() {
    
        Task {

            let messageId = await Courier.shared.sendPush(
                authKey: "a_courier_auth_key_that_should_only_be_used_for_testing",
                userId: "example_user",
                title: "Chirp Chrip!",
                body: "Hello from Courier 🐣",
                providers: [.apns, .fcm],
            )

        }
    
    }

}

class AppDelegate: CourierDelegate {

    ..

    override func pushNotificationDeliveredInForeground(message: [AnyHashable : Any]) -> UNNotificationPresentationOptions {
        print(message)
        return [.sound, .list, .banner, .badge] // Pass [] to hide any foreground presentation
    }

}
```

&emsp;
