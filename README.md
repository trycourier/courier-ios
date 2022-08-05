# **🐤 Courier — iOS**

Courier helps you spend less time building notification infrastructure, and more time building great experiences for your users!

[https://courier.com](https://www.courier.com/)

&emsp;

## **Installation (6 Steps)**

The following steps will get the Courier iOS SDK setup and allow support for sending push notifications from Courier to your device.

Full examples:
- [Swift + Storyboard + Apple Push Notification Service (APNS)](https://github.com/trycourier/courier-ios/tree/master/Examples/Swift%2BStoryboard%2BAPNS)
- [Swift + Storyboard + Firebase Cloud Messaging (FCM)](https://github.com/trycourier/courier-ios/tree/master/Examples/Swift%2BStoryboard%2BFCM)

⚠️ You need a physical iPhone or iPad to receive push notifications. You cannot test this effectively using the simulator.

&emsp;

### **1. Add the Swift Package**

![Swift Package Setup](https://github.com/trycourier/courier-ios/blob/master/add-swift-package.gif)

1. In your Xcode project, go to File > Add Packages
2. Paste the following url in "Search or Enter Package URL"

```
https://github.com/trycourier/courier-ios
```

3. Click "Add Package"

&emsp;

### **2. Manage User Credentials**

User Credentials must be set in Courier before they can receive push notifications. This should be handled where you normally manage your user's state.

⚠️ User Credentials should be [signed out](#6-signing-users-out) when you no longer want that user to receive push notifications.

⚠️ Courier does not maintain user state between app sessions, or in other words, if you force close the app, you will need to set user credentials again. We will be looking into maintaining user credential state between app sessions in future versions of this SDK.

```swift
import Courier

func signInWithCourier() {
    
    Task.init {

        let userId = "example_user"
        
        // Courier needs you to generate an access token on your backend
        // Docs for setting this up: https://www.courier.com/docs/reference/auth/issue-token/
        let accessToken = try await YourBackend.generateCourierAccessToken(userId: userId)

        // Set Courier user credentials
        try await Courier.shared.setCredentials(accessToken: accessToken, userId: userId)

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

### **(Recommended) Setup the Courier Notification Service**

Without adding the Courier Notification Service your Courier workspace will not know when Courier delivers a push notification to the device.

Follow this tutorial to setup the service! (No Code Required 😄)

![Entitlement setup](https://github.com/trycourier/courier-ios/blob/master/service-extension-tutorial.gif)

1. Run the script located at Xcode > Package Dependencies > Courier > TemplateBuilder > make_template.sh (`sh make_template.sh`)
2. Go back to Xcode and click File > New > Target
3. Under iOS, filter for "Courier"
4. Click Next
5. Give the service extension a name (i.e. "CourierService")
6. Click Finish
7. Click on your project file
8. Under Targets, click on your new Target
9. Under the General tab > Frameworks and Libraries, click the "+" icon
10. Select the Courier package from the list under Courier Package > Courier

&emsp;

### **4. Manage Push Notification Tokens**

There are few different ways to manage user tokens. Here are 3 examples:

&emsp;

### 1. `CourierDelegate` Example (Automatically manage APNS tokens)

`CourierDelegate` automatically synchronizes APNS tokens and simplifies receiving and opening push notifications.

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

### 2. Traditional APNS Example (Manually manage APNS tokens)

⚠️ Be sure to call both `Courier.shared.setCredentials(...)` and `Courier.shared.setPushToken(...)` in your implementation. Details can be found here: [Manage User Credentials](#2-manage-user-credentials)

```swift
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
                print(error)
            }
        }

    }

}
```

&emsp;

### 3. Traditional FCM Example (Manually manage FCM tokens)

⚠️ Be sure to call both `Courier.shared.setCredentials(...)` and `Courier.shared.setPushToken(...)` in your implementation. Details can be found here: [Manage User Credentials](#2-manage-user-credentials)

```swift
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
                    print(error)
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

&emsp;

### **Bonus! Sending a Test Push Notification**

⚠️ This is only for testing purposes and should not be in your production app.

```swift
import Courier

func sendTestMessage() {
    
    Task.init {

        let userId = "example_user_id"
        
        try await Courier.shared.sendPush(
            authKey: "your_api_key_that_should_not_stay_in_your_production_app",
            userId: userId,
            title: "Test message!",
            message: "Chrip Chirp!"
        )

    }
    
}
```

&emsp;

### **Share feedback with Courier**

We want to make this the best SDK for managing notifications! Have an idea or feedback about our SDKs? Here are some links to contact us:

- [Courier Feedback](https://feedback.courier.com/)
- [Courier iOS Issues](https://github.com/trycourier/courier-ios/issues)
