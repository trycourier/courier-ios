<img width="1000" alt="banner" src="https://user-images.githubusercontent.com/6370613/228920880-76fe5786-1baf-4525-a9d8-9f8a669ae95b.png">

&emsp;

# Requirements & Support

&emsp;

<table>
    <thead>
        <tr>
            <th width="880px" align="left">Requirements</th>
            <th width="120px" align="center"></th>
        </tr>
    </thead>
    <tbody>
        <tr width="600px">
            <td align="left">Courier Account</td>
            <td align="center">
                <a href="https://app.courier.com/channels/courier">
                    <code>Sign Up</code>
                </a>
            </td>
        </tr>
        <tr width="600px">
            <td align="left">Minimum iOS SDK Version</td>
            <td align="center">
                <code>13.0</code>
            </td>
        </tr>
    </tbody>
</table>

&emsp;

<table>
    <thead>
        <tr>
            <th width="880px" align="left">Languages</th>
            <th width="120px" align="center"></th>
        </tr>
    </thead>
    <tbody>
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

<table>
    <thead>
        <tr>
            <th width="880px" align="left">Package Manager</th>
            <th width="120px" align="center"></th>
        </tr>
    </thead>
    <tbody>
        <tr width="600px">
            <td align="left">
                <a href="https://github.com/trycourier/courier-ios/tree/master#using-swift-package-manager">
                    <code>Swift Package Manager</code>
                </a>
            </td>
            <td align="center">✅</td>
        </tr>
        <tr width="600px">
            <td align="left">
                <a href="https://github.com/trycourier/courier-ios/tree/master#using-cocoapods">
                    <code>Cocoapods</code>
                </a>
            </td>
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

1. Open your iOS project and increase the min SDK target to iOS 13.0+
2. Update Podfile

```ruby
platform :ios, '13.0'
..
target 'YOUR_TARGET_NAME' do
    ..
    pod 'Courier_iOS'
    ..
end
```

3. Open terminal in root directory and run

```sh
pod install
```

&emsp;

# Getting Started

These are all the available features of the SDK.

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
                <a href="https://github.com/trycourier/courier-ios/blob/master/Docs/Authentication.md">
                    <code>Authentication</code>
                </a>
            </td>
            <td align="left">
                Manages user credentials between app sessions.
            </td>
        </tr>
        <tr width="600px">
            <td align="left">
                <a href="https://github.com/trycourier/courier-ios/blob/master/Docs/Inbox.md">
                    <code>Courier Inbox</code>
                </a>
            </td>
            <td align="left">
                An in-app notification center you can use to notify your users.
            </td>
        </tr>
        <tr width="600px">
            <td align="left">
                <a href="https://github.com/trycourier/courier-ios/blob/master/Docs/PushNotifications.md">
                    <code>Push Notifications</code>
                </a>
            </td>
            <td align="left">
                Automatically manages push notification device tokens and gives convenient functions for handling push notification receiving and clicking.
            </td>
        </tr>
        <tr width="600px">
            <td align="left">
                <a href="https://github.com/trycourier/courier-ios/blob/master/Docs/Testing.md">
                    <code>Testing</code>
                </a>
            </td>
            <td align="left">
                Send inbox messages and push notifications to your device without needing any server side setup.
            </td>
        </tr>
    </tbody>
</table>

&emsp;

# Example Projects

Several common starter projects using the SDK.

<table>
    <thead>
        <tr>
            <th width="400px" align="left">Project Link</th>
            <th width="200px" align="center">UI Framework</th>
            <th width="200px" align="center">Package Manager</th>
            <th width="200px" align="center">Language</th>
        </tr>
    </thead>
    <tbody>
        <tr width="600px">
            <td align="left">
                <a href="https://github.com/trycourier/courier-ios/tree/master/Example">
                    <code>Example</code>
                </a>
            </td>
            <td align="center"><code>UIKit</code></td>
            <td align="center"><code>Swift</code></td>
            <td align="center"><code>Swift</code></td>
        </tr>
        <tr width="600px">
            <td align="left">
                <a href="https://github.com/trycourier/courier-ios/tree/master/Pod-Example">
                    <code>Example</code>
                </a>
            </td>
            <td align="center"><code>UIKit</code></td>
            <td align="center"><code>Cocoapods</code></td>
            <td align="center"><code>Swift</code></td>
        </tr>
        <tr width="600px">
            <td align="left">
                <a href="https://github.com/trycourier/courier-ios/tree/master/SwiftUI-Example">
                    <code>Example</code>
                </a>
            </td>
            <td align="center"><code>SwiftUI</code></td>
            <td align="center"><code>Swift</code></td>
            <td align="center"><code>Swift</code></td>
        </tr>
    </tbody>
</table>

&emsp;

## **Share feedback with Courier**

We are building the best SDKs for handling notifications! Have an idea or feedback about our SDKs? Here are some links to contact us:

- [Courier Feedback](https://feedback.courier.com/)
- [Courier iOS Issues](https://github.com/trycourier/courier-ios/issues)
