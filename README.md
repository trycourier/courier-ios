BANNER

# Requirements

⚠️ You must have a Courier account in order to use this SDK
[`Create a free Courier account`](https://app.courier.com/signup)

&emsp;

<table>
    <thead>
        <tr>
            <th width="900px" align="left">iOS Feature</th>
            <th width="100px" align="center">Support</th>
        </tr>
    </thead>
    <tbody>
        <tr width="600px">
            <td align="left">Minimum SDK Version</td>
            <td align="center">
                <code>13.0</code>
            </td>
        </tr>
        <tr width="600px">
            <td align="left">Swift</td>
            <td align="center">✅</td>
        </tr>
        <tr width="600px">
            <td align="left">Objective-C</td>
            <td align="center">✅</td>
        </tr>
    </tbody>
</table>

&emsp;

# Installation

## Using Swift Package Manager

https://user-images.githubusercontent.com/29832989/202578202-32c0ebf7-c11f-46c0-905a-daa8fc3ba8bd.mov

1. Open your iOS project and increase the min SDK target to iOS 13.0+
2. In your Xcode project, go to File > Add Packages
3. Paste the following url in "Search or Enter Package URL"

```
https://github.com/trycourier/courier-ios
```

## Using Cocoapods
1. Update Podfile for ios 13.0+
```ruby
platform :ios, '13.0'
..
target 'YOUR_TARGET_NAME' do
    ..
    pod 'Courier_iOS'
    ..
end
```
2. Open terminal in root directory and run
```sh
pod install
```
&emsp;

# SDK Features

These are all the available features of the SDK. Install all the ones that make sense for the user experience you are building.

<table>
    <thead>
        <tr>
            <th width="250px" align="left">Feature</th>
            <th width="750px" align="left">Description</th>
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
                Manages the current user and api keys between app sessions
            </td>
        </tr>
        <tr width="600px">
            <td align="left">
                <a href="https://github.com/trycourier/courier-ios/blob/feature/inbox-docs/Docs/Inbox.md">
                    <code>Courier Inbox</code>
                </a>
            </td>
            <td align="left">
                An in-app notification center list you can use to notify you users. Allows you to build experiences like the facebook notification feed very quickly.
            </td>
        </tr>
        <tr width="600px">
            <td align="left">
                <a href="https://github.com/trycourier/courier-ios/blob/feature/inbox-docs/Docs/PushNotifications.md">
                    <code>Push Notifications</code>
                </a>
            </td>
            <td align="left">
                Automatically manages push notification tokens and gives convenient functions for handling push notification receiving and clicking.
            </td>
        </tr>
        <tr width="600px">
            <td align="left">
                <a href="https://github.com/trycourier/courier-ios/blob/feature/inbox-docs/Docs/Testing.md">
                    <code>Testing</code>
                </a>
            </td>
            <td align="left">
                Send inbox messages and push notifications to your device without needing any server side setup
            </td>
        </tr>
    </tbody>
</table>

&emsp;

# Example Projects

These projects are working examples you can use as a base to build your project from.

<table>
    <thead>
        <tr>
            <th width="400px" align="left">Language</th>
            <th width="200px" align="center">UI Framework</th>
            <th width="200px" align="center">Package Manager</th>
            <th width="200px" align="center">Project</th>
        </tr>
    </thead>
    <tbody>
        <tr width="600px">
            <td align="left"><code>Swift</code></td>
            <td align="center"><code>UIKit</code></td>
            <td align="center"><code>Swift</code></td>
            <td align="center">
                <a href="https://github.com/trycourier/courier-ios/tree/feature/inbox-docs/Example">
                    <code>Project Link</code>
                </a>
            </td>
        </tr>
        <tr width="600px">
            <td align="left"><code>Swift</code></td>
            <td align="center"><code>UIKit</code></td>
            <td align="center"><code>Cocoapods</code></td>
            <td align="center">
                <a href="https://github.com/trycourier/courier-ios/tree/feature/inbox-docs/Pod-Example">
                    <code>Project Link</code>
                </a>
            </td>
        </tr>
        <tr width="600px">
            <td align="left"><code>Swift</code></td>
            <td align="center"><code>SwiftUI</code></td>
            <td align="center"><code>Swift</code></td>
            <td align="center">
                <a href="https://github.com/trycourier/courier-ios/tree/feature/inbox-docs/SwiftUI-Example">
                    <code>Project Link</code>
                </a>
            </td>
        </tr>
    </tbody>
</table>

&emsp;

## **Share feedback with Courier**

We are building the best SDKs for handling notifications! Have an idea or feedback about our SDKs? Here are some links to contact us:

- [Courier Feedback](https://feedback.courier.com/)
- [Courier iOS Issues](https://github.com/trycourier/courier-ios/issues)
