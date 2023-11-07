<img width="1000" alt="push-banner" src="https://user-images.githubusercontent.com/6370613/229574537-0d45260f-120a-4b88-80b0-59880860bb46.png">

&emsp;

# Push Notifications

The easiest way to support push notifications in your app.

## Features

<table>
    <thead>
        <tr>
            <th width="300px" align="left">Feature</th>
            <th width="750px" align="left">Description</th>
        </tr>
    </thead>
    <tbody>
        <tr width="600px">
            <td align="left">
                <a href="https://github.com/trycourier/courier-ios/blob/master/Docs/PushNotifications.md#3-implement-the-courierdelegate">
                    <code>Automatic Token Management</code>
                </a>
            </td>
            <td align="left">
                Skip manually managing push notification device tokens.
            </td>
        </tr>
        <tr width="600px">
            <td align="left">
                <a href="https://github.com/trycourier/courier-ios/blob/master/Docs/PushNotifications.md#3-implement-the-courierdelegate">
                    <code>Notification Tracking</code>
                </a>
            </td>
            <td align="left">
                Track if your users are receiving your notifications even if your app is not runnning or open.
            </td>
        </tr>
        <tr width="600px">
            <td align="left">
                <a href="https://github.com/trycourier/courier-ios/blob/master/Docs/PushNotifications.md#5-send-a-test-push-notification">
                    <code>Permission Requests & Checking</code>
                </a>
            </td>
            <td align="left">
                Simple functions to request and check push notification permission settings.
            </td>
        </tr>
    </tbody>
</table>

&emsp;

## Requirements

<table>
    <thead>
        <tr>
            <th width="300px" align="left">Requirement</th>
            <th width="750px" align="left">Reason</th>
        </tr>
    </thead>
    <tbody>
        <tr width="600px">
            <td align="left">
                <a href="https://developer.apple.com/account/">
                    <code>Apple Developer Membership</code>
                </a>
            </td>
            <td align="left">
                Apple requires all iOS developers to have a membership so you can manage your push notification certificates.
            </td>
        </tr>
        <tr width="600px">
            <td align="left">
                A phyical iOS device
            </td>
            <td align="left">
                Although you can setup the Courier SDK without a device, a physical device is the only way to fully ensure push notification tokens and notification delivery is working correctly. Simulators are not reliable.
            </td>
        </tr>
        <tr width="600px">
            <td align="left">
                <a href="https://github.com/trycourier/courier-ios/blob/master/Docs/PushNotifications.md#1-setup-a-push-notification-provider">
                    <code>A Configured Provider</code>
                </a>
            </td>
            <td align="left">
                Courier needs to know who to route the push notifications to so your users can receive them.
            </td>
        </tr>
        <tr width="600px">
            <td align="left">
                <a href="https://github.com/trycourier/courier-ios/blob/master/Docs/Authentication.md">
                    <code>Authentication</code>
                </a>
            </td>
            <td align="left">
                Needs Authentication to sync push notification device tokens to the current user and Courier.
            </td>
        </tr>
    </tbody>
</table>

&emsp;

# Setup 

## 1. Setup a Push Notification Provider

Select which push notification provider you would like Courier to route push notifications to. Choose APNS - Apple Push Notification Service if you are not sure which provider to use.

<table>
    <thead>
        <tr>
            <th width="850px" align="left">Provider</th>
            <th width="200px" align="center">Token Syncing</th>
        </tr>
    </thead>
    <tbody>
        <tr width="600px">
            <td align="left">
                <a href="https://app.courier.com/channels/apn">
                    <code>(APNS) - Apple Push Notification Service</code>
                </a>
            </td>
            <td align="center">
                <a href="https://github.com/trycourier/courier-ios/blob/master/Docs/PushNotifications.md#automatic-token-syncing-apns-only">
                    <code>Automatic</code>
                </a>
            </td>
        </tr>
        <tr width="600px">
            <td align="left">
                <a href="https://app.courier.com/channels/firebase-fcm">
                    <code>(FCM) - Firebase Cloud Messaging</code>
                </a>
            </td>
            <td align="center">
                <a href="https://github.com/trycourier/courier-ios/blob/master/Docs/PushNotifications.md#fcm---firebase-cloud-messaging-support">
                    <code>Manual</code>
                </a>
            </td>
        </tr>
        <tr width="600px">
            <td align="left">
                <a href="https://app.courier.com/channels/onesignal">
                    <code>OneSignal</code>
                </a>
            </td>
            <td align="center">
                <a href="https://github.com/trycourier/courier-ios/blob/master/Docs/PushNotifications.md#fcm---firebase-cloud-messaging-support">
                    <code>TODO</code>
                </a>
            </td>
        </tr>
    </tbody>
</table>

&emsp;

## 2. Enable the "Push Notifications" capability 

https://user-images.githubusercontent.com/29832989/204891095-1b9ac4f4-8e5f-4c71-8e8f-bf77dc0a2bf3.mov
1. Select your Xcode project file
2. Click your project Target
3. Click "Signing & Capabilities"
4. Click the small "+" to add a capability
4. Press Enter

&emsp;

## 3. Sync Push Notification Tokens

### Automatic Token Syncing (APNS Only)

1. In your `AppDelegate`, add `import Courier_iOS`
2. Change your `AppDelegate` to extend the `CourierDelegate`
    * This automatically syncs APNS tokens to Courier
    * This adds simple functions to handle push notification delivery and clicks
    
```swift
import Courier_iOS

@main
class AppDelegate: CourierDelegate {
    
    ...

    override func pushNotificationDeliveredInForeground(message: [AnyHashable : Any]) -> UNNotificationPresentationOptions {
        
        print("\n=== 💌 Push Notification Delivered In Foreground ===\n")
        print(message)
        print("\n=================================================\n")
        
        // This is how you want to show your notification in the foreground
        // You can pass "[]" to not show the notification to the user or
        // handle this with your own custom styles
        return [.sound, .list, .banner, .badge]
        
    }
    
    override func pushNotificationClicked(message: [AnyHashable : Any]) {
        
        print("\n=== 👉 Push Notification Clicked ===\n")
        print(message)
        print("\n=================================\n")
        
        showMessageAlert(title: "Message Clicked", message: "\(message)")
        
    }

}
```
    
### Manual Token Syncing

Useful if you do not want to use `CourierDelegate` or you would like to sync tokens from another provider into Courier.

```swift
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    ...

    // Manually Sync APNS tokens
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {

        Task {

            // Raw APNS token
            try await Courier.shared.setAPNSToken(deviceToken)

            // APNS token strings
            try await Courier.shared.setToken(provider: .apn, token: deviceToken.string)
            
        }

    }

    // Commonly used with Firebase Cloud Messaging and other providers
    func yourTokenFetchingFunction(token: String) {

        Task {

            // Sync with provider
            // Available providers: .apn, .firebaseFcm, .expo, .oneSignal, .pusherBeams
            try await Courier.shared.setToken(provider: .firebaseFcm, token: token)

            // Sync with key
            // Any string as key is supported. Make sure you are using the proper key for your needs.
            try await Courier.shared.setToken(provider: "firebase-fcm", token: token)
            
        }

    }

}
```

&emsp;

## 4. Add the Notification Service Extension (Optional, but recommended)

To make sure Courier can track when a notification is delivered to the device, you need to add a Notification Service Extension. Here is how to add one.

https://user-images.githubusercontent.com/29832989/202580269-863a9293-4c0b-48c9-8485-c0c43f077e12.mov

1. Download and Unzip the Courier Notification Service Extension: [`CourierNotificationServiceTemplate.zip`](https://github.com/trycourier/courier-notification-service-extension-template/archive/refs/heads/main.zip)
2. Open the folder in terminal and run `sh make_template.sh`
    - This will create the Notification Service Extension on your mac to save you time
3. Open your iOS app in Xcode and go to File > New > Target
4. Select "Courier Service" and click "Next"
5. Give the Notification Service Extension a name (i.e. "CourierService").
6. Click Finish

### Link the Courier SDK to your extension:

#### Swift Package Manager Setup
1. Click on your project file
2. Under Targets, click on your new Target
3. Under the General tab > Frameworks and Libraries, click the "+" icon
4. Select the Courier package from the list under Courier Package > Courier

#### Cocoapods Setup
1. Add the following snippet to the bottom of your Podfile

```ruby 
target 'CourierService' do
    pod 'Courier_iOS'
end
```

2. Run `pod install`

&emsp;

## 5. Send a Test Push Notification

1. Register for push notifications

```swift
import Courier_iOS

Task {
                    
    // Make sure your user is signed into Courier
    // This will take the tokens you are wanting to sync above, and save them to this user id
    // Put this where you normally manage your user's state
    try await Courier.shared.signIn(
        accessToken: Env.COURIER_ACCESS_TOKEN,
        userId: "example_user_id"
    )

    // Shows a popup where your user can allow or deny push notifications
    // You should put this in a place that makes sense for your app
    // You cannot ask the user for push notification permissions again
    // if they deny, you will have to get them to open their device settings to change this
    let status = try await Courier.requestNotificationPermission()

}
```

2. Send a test message

<table>
    <thead>
        <tr>
            <th width="600px" align="left">Provider</th>
            <th width="200px" align="center">Link</th>
        </tr>
    </thead>
    <tbody>
        <tr width="600px">
            <td align="left">
                <a href="https://app.courier.com/channels/apn">
                    <code>(APNS) - Apple Push Notification Service</code>
                </a>
            </td>
            <td align="center">
                <a href="https://www.courier.com/docs/platform/channels/push/apple-push-notification/#sending-messages">
                    <code>Testing Docs</code>
                </a>
            </td>
        </tr>
        <tr width="600px">
            <td align="left">
                <a href="https://app.courier.com/channels/firebase-fcm">
                    <code>(FCM) - Firebase Cloud Messaging</code>
                </a>
            </td>
            <td align="center">
                <a href="https://www.courier.com/docs/platform/channels/push/firebase-fcm/#sending-messages">
                    <code>Testing Docs</code>
                </a>
            </td>
        </tr>
    </tbody>
</table>
