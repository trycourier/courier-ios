BANNER

# Requirements

### **Supported iOS Features**

> ⚠️ You must have a Courier account in order to use this SDK. [`Create a Courier account for free here!`](https://app.courier.com/signup)

<table>
    <thead>
        <tr>
            <th width="900px" align="left">Feature</th>
            <th width="100px" align="center">Support</th>
        </tr>
    </thead>
    <tbody>
        <tr width="600px">
            <td align="left">Minimum iOS SDK Version</td>
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

&emsp;

## **Install the package**
### Using Swift Package Manager

https://user-images.githubusercontent.com/29832989/202578202-32c0ebf7-c11f-46c0-905a-daa8fc3ba8bd.mov

1. Open your iOS project and increase the min SDK target to iOS 13.0+
2. In your Xcode project, go to File > Add Packages
3. Paste the following url in "Search or Enter Package URL"

```
https://github.com/trycourier/courier-ios
```

### Using Cocoapods
1. Update Podfile for ios 13.0+
```ruby
platform :ios, '13.0'
```
2. Add `pod 'Courier-iOS'` in your base target
3. Open terminal in root directory and run
```sh
pod install
```
&emsp;

<table>
    <thead>
        <tr>
            <th width="800px" align="left">SDK Feature</th>
            <th width="200px" align="center">Documentation</th>
        </tr>
    </thead>
    <tbody>
        <tr width="600px">
            <td align="left">Authentication</td>
            <td align="center">
                <a href="https://github.com/trycourier/courier-ios/blob/feature/inbox-docs/Docs/Authentication.md">
                    <code>Auth Docs</code>
                </a>
            </td>
        </tr>
        <tr width="600px">
            <td align="left">Courier Inbox (In-app notification center)</td>
            <td align="center">
                <a href="https://github.com/trycourier/courier-ios/blob/feature/inbox-docs/Docs/Inbox.md">
                    <code>Inbox Docs</code>
                </a>
            </td>
        </tr>
        <tr width="600px">
            <td align="left">Push Notifications</td>
            <td align="center">
                <a href="https://github.com/trycourier/courier-ios/blob/feature/inbox-docs/Docs/PushNotifications.md">
                    <code>Push Docs</code>
                </a>
            </td>
        </tr>
        <tr width="600px">
            <td align="left">Testing</td>
            <td align="center">
                <a href="https://github.com/trycourier/courier-ios/blob/feature/inbox-docs/Docs/Testing.md">
                    <code>Testing Docs</code>
                </a>
            </td>
        </tr>
    </tbody>
</table>

# Examples

<table>
    <thead>
        <tr>
            <th width="400px" align="left">UI Framework</th>
            <th width="200px" align="center">Language</th>
            <th width="200px" align="center">Package Manager</th>
            <th width="200px" align="center">Project</th>
        </tr>
    </thead>
    <tbody>
        <tr width="600px">
            <td align="left"><code>UIKit</code></td>
            <td align="center"><code>Swift</code></td>
            <td align="center"><code>Swift</code></td>
            <td align="center">
                <a href="https://github.com/trycourier/courier-ios/tree/feature/inbox-docs/Example">
                    <code>Project Link</code>
                </a>
            </td>
        </tr>
        <tr width="600px">
            <td align="left"><code>UIKit</code></td>
            <td align="center"><code>Swift</code></td>
            <td align="center"><code>Cocoapods</code></td>
            <td align="center">
                <a href="https://github.com/trycourier/courier-ios/tree/feature/inbox-docs/Pod-Example">
                    <code>Project Link</code>
                </a>
            </td>
        </tr>
        <tr width="600px">
            <td align="left"><code>SwiftUI</code></td>
            <td align="center"><code>Swift</code></td>
            <td align="center"><code>Swift</code></td>
            <td align="center">
                <a href="https://github.com/trycourier/courier-ios/tree/feature/inbox-docs/SwiftUI-Example">
                    <code>Project Link</code>
                </a>
            </td>
        </tr>
    </tbody>
</table>

>
> Link to [`Example App`](https://github.com/trycourier/courier-ios/tree/master/Example)
>

## **Share feedback with Courier**

We are building the best SDKs for handling notifications! Have an idea or feedback about our SDKs? Here are some links to contact us:

- [Courier Feedback](https://feedback.courier.com/)
- [Courier iOS Issues](https://github.com/trycourier/courier-ios/issues)
