# **Courier 🐤**

Courier helps you spend less time building notification infrastructure, and more time building great experiences for your users!

[https://courier.com](https://www.courier.com/)

&emsp;

## **Installation (5 Steps)**

The following steps will get the Courier iOS SDK setup and allow support for sending push notifications from Courier to your device.

&emsp;

### **1. Add the Swift Package**
1. In your Xcode project, go to File > Add Packages
2. Paste the following url in "Search or Enter Package URL"

```
https://github.com/trycourier/courier-ios
```

3. Click "Add Package"

&emsp;

### **2. Initialize the SDK**

_The following will show you how to install the SDK using a standard Swift + Storyboard project. Other examples can be found here: [Courier iOS Example Projects](https://github.com/trycourier/courier-ios/tree/master/Examples)_

1. Add the following to your `AppDelegate` to initialize the SDK.

```swift
...
import Courier

class AppDelegate: CourierDelegate {

    ...

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        ...

        Courier.shared.authorizationKey = your_auth_key

        ...

        return true
    }

    ...

}
```

2. Change `your_auth_key` to use an authentication key you'd like from here: [Courier Authentication Keys](https://app.courier.com/settings/api-keys)

&emsp;

### **3. Enable Push Notification Capability**

1. Select your Xcode project file
2. Click your project Target
3. Click "Signing & Capabilities"
4. Click the small "+" to add a capability
5. Type "Push Notifications"
6. Press Enter

&emsp;

### **4. Handle Push Notifications**

1. Add the following to your `AppDelegate` to support push notifications

```swift

...

class AppDelegate: CourierDelegate {

    ...

        override func pushNotificationReceivedInForeground(message: [AnyHashable : Any], presentAs showForegroundNotificationAs: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        print("Push Received")
        print(message)
        
        // ⚠️ Customize this to be what you would like
        // Pass an empty array to this if you do not want to use it
        showForegroundNotificationAs([.list, .badge, .banner, .sound])
        
    }
    
    override func pushNotificationOpened(message: [AnyHashable : Any]) {

        print("Push Opened")
        print(message)

    }

    ...

}
```

_These are optional functions and should be used however would be best for the user experience you are trying to build._

&emsp;

### **4. Configure a Provider**

To get pushes to appear, add support for the provider you would like to use. Checkout the following tutorials to get a push provider setup.

- [Apple Push Notification Service](https://www.courier.com/docs/guides/providers/push/apple-push-notification)
- [Firebase Cloud Messaging](https://www.courier.com/docs/guides/providers/push/firebase-fcm/)

&emsp;

### **5. Send a Test Push Notification**

The following code:
- Registers a user in Courier
- Requests Push Notification Permissions
- Sends a Test Message

Please add this to your project in a place the makes the most sense for the user experience you are building. 

_This example uses async await found in newer versions of Swift. More complete examples can be found here: [Courier iOS Example Projects](https://github.com/trycourier/courier-ios/tree/master/Examples)_

```swift
...
import Courier

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Task.init {

            let userId = "example_user_id"

            // Create a user in courier
            // This should be called everytime your user's authentication state changes
            let user = CourierUser(id: userId)
            try await Courier.shared.setUser(user)

            // Request push notification permissions
            // status must be .authorized for notifications to appear
            let status = try await Courier.requestNotificationPermissions()

            // Send test push notification
            try await Courier.sendTestMessage(
                userId: userId,
                title: "Test message!",
                message: "Chrip Chirp!"
            )

        }
        
    }

}
```

### **6. Signing Users Out**

Best user experience practice is to synchronize the current user's push notification tokens and the user's state. 

To handle this with Courier, simply:

1. Call `Courier.shared.setUser(...)` when your user signs into your app
2. Call `Courier.shared.signOut()` when your user signs out if your app

If you do not call `Courier.shared.signOut()` it is possible that user's that sign out will still receive push notifications as if they are signed in.

