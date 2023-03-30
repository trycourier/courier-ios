<img width="1000" alt="push-banner" src="https://user-images.githubusercontent.com/6370613/228950476-c2eb81fb-5ab8-44fe-b1bf-2ec8af98555a.png">

&emsp;

# Push Notifications

The easiest way to support push notifications in your app.

## Features

<table>
    <thead>
        <tr>
            <th width="350px" align="left">Feature</th>
            <th width="650px" align="left">Description</th>
        </tr>
    </thead>
    <tbody>
        <tr width="600px">
            <td align="left">
                <a href="TODO">
                    <code>Automatic Token Management</code>
                </a>
            </td>
            <td align="left">
                Skip manually managing push notification device tokens.
            </td>
        </tr>
        <tr width="600px">
            <td align="left">
                <a href="TODO">
                    <code>Notification Tracking</code>
                </a>
            </td>
            <td align="left">
                Track if your users are receiving your notifications even if your app is not runnning or open.
            </td>
        </tr>
        <tr width="600px">
            <td align="left">
                <a href="TODO">
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
            <th width="700px" align="left">Reason</th>
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
                Although you can setup the Courier SDK without a device, a physical device is the only way to full ensure push notification tokens and notification delivery is working correctly. Simulators are not reliable.
            </td>
        </tr>
        <tr width="600px">
            <td align="left">
                <a href="https://github.com/trycourier/courier-ios/blob/feature/inbox-docs/Docs/Authentication.md">
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

## Supported Providers

<table>
    <thead>
        <tr>
            <th width="580px" align="left">Provider</th>
            <th width="220px" align="center">Token Syncing</th>
            <th width="200px" align="center">Supported</th>
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
                <code>Automatic</code>
            </td>
            <td align="center">✅</td>
        </tr>
        <tr width="600px">
            <td align="left">
                <a href="https://app.courier.com/channels/firebase-fcm">
                    <code>(FCM) - Firebase Cloud Messaging</code>
                </a>
            </td>
            <td align="center">
                <a href="TODO">
                    <code>Manual</code>
                </a>
            </td>
            <td align="center">✅</td>
        </tr>
        <tr width="600px">
            <td align="left">
                <a href="https://app.courier.com/channels/expo">
                    <code>Expo</code>
                </a>
            </td>
            <td align="center">
                —
            </td>
            <td align="center">❌</td>
        </tr>
        <tr width="600px">
            <td align="left">
                <a href="https://app.courier.com/channels/onesignal">
                    <code>OneSignal</code>
                </a>
            </td>
            <td align="center">
                —
            </td>
            <td align="center">❌</td>
        </tr>
    </tbody>
</table>

&emsp;

### **Supported Messaging Providers**

> ⚠️ Testing push notifications should be done with a physical iPhone or iPad. The iOS simulator is inconsistent to test with.

<table>
    <thead>
        <tr>
            <th width="800px" align="left">Provider</th>
            <th width="100px" align="center">Support</th>
            <th width="100px" align="center">Config</th>
        </tr>
    </thead>
    <tbody>
        <tr width="600px">
            <td align="left">Firebase Cloud Messaging (FCM)</td>
            <td align="center">✅</td>
            <td align="center">Push</td>
            <td align="center">
                <a href="https://app.courier.com/channels/firebase-fcm">
                    <code>Setup</code>
                </a>
            </td>
        </tr>
        <tr width="600px">
            <td align="left">Apple Push Notification Service (APNS)</td>
            <td align="center">✅</td>
            <td align="center">Push</td>
            <td align="center">
                <a href="https://app.courier.com/channels/apn">
                    <code>Setup</code>
                </a>
            </td>
        </tr>
        <tr width="600px">
            <td align="left">Expo</td>
            <td align="center">❌</td>
            <td align="center">Push</td>
            <td align="center">
                <a href="https://app.courier.com/channels/expo">
                    <code>Setup</code>
                </a>
            </td>
        </tr>
        <tr width="600px">
            <td align="left">OneSignal</td>
            <td align="center">❌</td>
            <td align="center">Push</td>
            <td align="center">
                <a href="https://app.courier.com/channels/onesignal">
                    <code>Setup</code>
                </a>
            </td>
        </tr>
    </tbody>
</table>

&emsp;

```swift

try await Courier.shared.setFCMToken(token)
try await Courier.shared.setAPNSToken(token)

let fcmToken = Courier.shared.fcmToken
let apnsToken = Courier.shared.apnsToken

let currentPermissionStatus = try await Courier.shared.getNotificationPermissionStatus()
let requestPermissionStatus = try await Courier.shared.requestNotificationPermission()

// Delivery handlers

class AppDelegate: CourierDelegate {

    override func pushNotificationDeliveredInForeground(message: [AnyHashable : Any]) -> UNNotificationPresentationOptions {
        print(message)
        return [.sound, .list, .banner, .badge]
    }
    
    override func pushNotificationClicked(message: [AnyHashable : Any]) {
        print(message)
    }

}

```

## **2. Setup**
1. Change your `AppDelegate` to extend the `CourierDelegate` and add `import Courier` to the top of your `AppDelegate` file
    - This automatically syncs APNS tokens to Courier
2. Enable the "Push Notifications" capability

https://user-images.githubusercontent.com/29832989/204891095-1b9ac4f4-8e5f-4c71-8e8f-bf77dc0a2bf3.mov
   <ol start="1" type="1">
       <li>Select your Xcode project file</li>
       <li>Click your project Target</li>
       <li>Click "Signing & Capabilities"</li>
       <li>Click the small "+" to add a capability</li>
       <li>Type "Push Notifications"</li>
       <li>Press Enter</li>
   </ol>

&emsp;

### **Add the Notification Service Extension (Recommended)**

To make sure Courier can track when a notification is delivered to the device, you need to add a Notification Service Extension. Here is how to add one.

https://user-images.githubusercontent.com/29832989/202580269-863a9293-4c0b-48c9-8485-c0c43f077e12.mov

1. Download and Unzip the Courier Notification Service Extension: [`CourierNotificationServiceTemplate.zip`](https://github.com/trycourier/courier-notification-service-extension-template/archive/refs/heads/main.zip)
2. Open the folder in terminal and run `sh make_template.sh`
    - This will create the Notification Service Extension on your mac to save you time
3. Open your iOS app in Xcode and go to File > New > Target
4. Select "Courier Service" and click "Next"
5. Give the Notification Service Extension a name (i.e. "CourierService").
6. Link the Courier SDK to your extension

#### If you are using Swift Package Manager
1. Select `Courier` from package dropdown
2. Click Finish
3. Click on your project file
4. Under Targets, click on your new Target
5. Under the General tab > Frameworks and Libraries, click the "+" icon
6. Select the Courier package from the list under Courier Package > Courier

#### If you are using Cocoapods
1. Select `Courier_iOS` from the package dropdown
2. Add the following snippet to the bottom of your Podfile

```ruby 
target 'CourierService' do
    pod 'Courier-iOS'
end
```

3. Run `pod install`

&emsp;

## **3. Configure Push Provider**

> If you don't need push notification support, you can skip this step.

To get push notification to appear in your app, add support for the provider you would like to use:
- [`APNS (Apple Push Notification Service)`](https://www.courier.com/docs/guides/providers/push/apple-push-notification)
- [`FCM (Firebase Cloud Messaging)`](https://www.courier.com/docs/guides/providers/push/firebase-fcm/)

&emsp;

If you followed the steps above:
- APNS tokens on iOS will automatically be synced to Courier

### **Support FCM (Firebase Cloud Messaging)**

1. Add the Firebase Package

#### If you are using Swift Package Manager
- Add the Firebase Swift Package [`firebase-ios-sdk`](https://github.com/firebase/firebase-ios-sdk)
- Select `firebase-messaging`

#### If you are using Cocoapods
- [`FirebaseCore`](https://cocoapods.org/pods/FirebaseCore)
- [`FirebaseMessaging`](https://cocoapods.org/pods/FirebaseMessaging)

2. Change your `AppDelegate` to also extend `MessagingDelegate`
3. Add `import FirebaseCore`, `import FirebaseMessaging` to the top of your `AppDelegate` file
4. Modify your `AppDelegate` according to the snippet below
    - This will automatically sync FCM tokens to Courier when Firebase detects them
    - If you need more custom integrations, you can call `Courier.shared.setFCMToken(token)` where ever works best for you
```swift
import UIKit
import Courier
import FirebaseCore
import FirebaseMessaging

@main
class AppDelegate: CourierDelegate, MessagingDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        return true
    }

    ..
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        
        guard let token = fcmToken else { return }
        
        Task {
            try await Courier.shared.setFCMToken(token)    
        }
        
    }

}
```

&emsp;
