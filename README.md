<img width="1000" alt="ios-banner" src="https://github.com/user-attachments/assets/3e7de20b-5b68-40df-90ca-057b18fd70ab">

&emsp;

# Requirements & Support

<table>
    <thead>
        <tr>
            <th width="940px" align="left">Requirements</th>
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

<table>
    <thead>
        <tr>
            <th width="940px" align="left">Package Managers</th>
            <th width="120px" align="center"></th>
        </tr>
    </thead>
    <tbody>
        <tr width="600px">
            <td align="left">
                <a href="https://github.com/trycourier/courier-ios#using-swift-package-manager">
                    <code>Swift Package Manager</code>
                </a>
            </td>
            <td align="center">✅</td>
        </tr>
        <tr width="600px">
            <td align="left">
                <a href="https://github.com/trycourier/courier-ios#using-cocoapods">
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
            <th width="25px"></th>
            <th width="250px" align="left">Feature</th>
            <th width="725px" align="left">Description</th>
        </tr>
    </thead>
    <tbody>
        <tr width="600px">
            <td align="center">
                1
            </td>
            <td align="left">
                <a href="https://github.com/trycourier/courier-ios/blob/master/Docs/1_Authentication.md">
                    <code>Authentication</code>
                </a>
            </td>
            <td align="left">
                Manages user credentials between app sessions. Required if you would like to use <a href="https://github.com/trycourier/courier-ios/blob/master/Docs/2_Inbox.md"><code>Inbox</code></a>, <a href="https://github.com/trycourier/courier-ios/blob/master/Docs/3_PushNotifications.md"><code>Push Notifications</code></a> and <a href="https://github.com/trycourier/courier-ios/blob/master/Docs/4_Preferences.md"><code>Preferences</code></a>.
            </td>
        </tr>
        <tr width="600px">
            <td align="center">
                2
            </td>
            <td align="left">
                <a href="https://github.com/trycourier/courier-ios/blob/master/Docs/2_Inbox.md">
                    <code>Inbox</code>
                </a>
            </td>
            <td align="left">
                An in-app notification center you can use to notify your users. Comes with a prebuilt UI and also supports fully custom UIs.
            </td>
        </tr>
        <tr width="600px">
            <td align="center">
                3
            </td>
            <td align="left">
                <a href="https://github.com/trycourier/courier-ios/blob/master/Docs/3_PushNotifications.md">
                    <code>Push Notifications</code>
                </a>
            </td>
            <td align="left">
                Automatically manages push notification device tokens and gives convenient functions for handling push notification receiving and clicking.
            </td>
        </tr>
        <tr width="600px">
            <td align="center">
                4
            </td>
            <td align="left">
                <a href="https://github.com/trycourier/courier-ios/blob/master/Docs/4_Preferences.md">
                    <code>Preferences</code>
                </a>
            </td>
            <td align="left">
                Allow users to update which types of notifications they would like to receive.
            </td>
        </tr>
        <tr width="600px">
            <td align="center">
                5
            </td>
            <td align="left">
                <a href="https://github.com/trycourier/courier-ios/blob/master/Docs/5_Client.md">
                    <code>CourierClient</code>
                </a>
            </td>
            <td align="left">
                The base level API wrapper around the Courier endpoints. Useful if you have a highly customized user experience or codebase requirements.
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
            <th width="450px" align="left">Project Link</th>
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
    </tbody>
</table>

&emsp;

# **Share feedback with Courier**

We want to make this the best SDK for managing notifications! Have an idea or feedback about our SDKs? Let us know!

[Courier iOS Issues](https://github.com/trycourier/courier-ios/issues)
