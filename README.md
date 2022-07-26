# **Courier 🐤**

Courier helps you spend less time building notification infrastructure, and more time building great experiences for your users!

[https://courier.com](https://www.courier.com/)

&emsp;

## **Installation (6 Steps)**

The following steps will get the Courier iOS SDK setup and allow support for sending push notifications from Courier to your device.

Full examples:
- [Swift + Storyboard + Apple Push Notification Service (APNS)](https://github.com/trycourier/courier-ios/tree/master/Examples/Swift%2BStoryboard%2BAPNS)
- [Swift + Storyboard + Firebase Cloud Messaging (FCM)](https://github.com/trycourier/courier-ios/tree/master/Examples/Swift%2BStoryboard%2BFCM)

&emsp;

### **1. Add the Swift Package**
1. In your Xcode project, go to File > Add Packages
2. Paste the following url in "Search or Enter Package URL"

```
https://github.com/trycourier/courier-ios
```

3. Click "Add Package"

&emsp;

### **2. Manage User Profiles**

User Profiles must be set in Courier before they can receive push notifications.
User Profiles should be signed out when you no longer want that user to receive push notifications.

```swift
import Courier

func signInWithCourier() {
    
    Task.init {

        let userId = "example_user_id"
        
        // Courier needs you to generate an access token on your backend
        // Docs for setting this up: https://www.courier.com/docs/reference/auth/issue-token/
        let accessToken = try await YourBackend.generateCourierAccessToken(userId: userId)

        // Create a user profile in Courier
        let user = CourierUserProfile(id: userId)
        try await Courier.shared.setUserProfile(accessToken: accessToken, userProfile: user)

    }
    
}
```

&emsp;

### **3. Enable Push Notifications**

![Entitlement setup](https://github.com/trycourier/courier-ios/blob/master/push-notification-entitlement.gif)

1. Select your Xcode project file
2. Click your project Target
3. Click "Signing & Capabilities"
4. Click the small "+" to add a capability
5. Type "Push Notifications"
6. Press Enter

&emsp;

### **4. Manage Push Notification Tokens**

&emsp;

Example with `CourierDelegate`.

_`CourierDelegate` automatically syncs APNS tokens and gives functions for handling push notifications very easily._

```swift
...
import Courier

class AppDelegate: CourierDelegate {

    ...

    override func pushNotificationReceivedInForeground(message: [AnyHashable : Any], presentAs showForegroundNotificationAs: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        // TODO: Remove this print
        print("Push Received")
        print(message)
        
        // ⚠️ Customize this to be what you would like
        // Pass an empty array to this if you do not want to use it
        showForegroundNotificationAs([.list, .badge, .banner, .sound])
        
    }
    
    override func pushNotificationOpened(message: [AnyHashable : Any]) {

        // TODO: Remove this print
        print("Push Opened")
        print(message)

    }

}
```

&emsp;

Traditional APNS Example

```swift
...
import Courier

class AppDelegate: UIResponder, UIApplicationDelegate {

    ...

    public func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {

        Task.init {
            do {
                let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
                try await Courier.shared.setPushToken(
                    provider: .apns,
                    token: token
                )
            } catch {
                debugPrint(error)
            }
        }

    }

    ...

}
```

Traditional FCM Example

```swift
...
import Courier

extension AppDelegate: MessagingDelegate {
  
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {

        if let token = fcmToken {

            Task.init {
                do {
                    try await Courier.shared.setPushToken(
                        provider: .fcm,
                        token: token
                    )
                } catch {
                    debugPrint(error)
                }
            }

        }

    }

}
```

_Other examples can be found here: [More Examples](https://github.com/trycourier/courier-ios/tree/master/Examples)_

&emsp;

### **5. Configure a Provider**

To get pushes to appear, add support for the provider you would like to use. Checkout the following tutorials to get a push provider setup.

- [Apple Push Notification Service](https://www.courier.com/docs/guides/providers/push/apple-push-notification)
- [Firebase Cloud Messaging](https://www.courier.com/docs/guides/providers/push/firebase-fcm/)

&emsp;

### **6. Signing Users Out**

Best user experience practice is to synchronize the current user's push notification tokens and the user's state. 

This should be called where you normally manage your user's state.

```swift
import Courier

func signOut() {
    
    Task.init {

        try await Courier.shared.signOut()

    }
    
}
```

### **Bonus! Sending a Test Push Notification**

_This is only for testing purposes and should not be in your production app._

```swift
import Courier

func sendTestMessage() {
    
    Task.init {

        let userId = "example_user_id"
        
        try await Courier.shared.sendTestMessage(
            authKey: "your_api_key",
            userId: userId,
            title: "Test message!",
            message: "Chrip Chirp!"
        )

    }
    
}
```