<!-- Generated from https://www.courier.com/docs/in-app/add-an-inbox by mintlify-docs. Edit the docs source, not this file. -->

# Add the Courier Inbox

> Install the SDK, sign the user in, and render the inbox component on any platform.

Source: https://www.courier.com/docs/in-app/add-an-inbox

Your backend generates the `jwt` in these snippets with your Courier API key. For the full flow, scope strings, and token refresh, see [Authenticate users](https://www.courier.com/docs/in-app/authenticate-users).

## Prerequisites

- [A Courier account](https://app.courier.com/signup)
- [A Courier API key](https://app.courier.com/settings/api-keys)
- [A backend endpoint that issues a Courier JWT](https://www.courier.com/docs/in-app/authenticate-users)
- A message sent to that user on the `inbox` channel

## Set up

### Install the SDK

Install the SDK for your framework.

```bash
# Xcode: File > Add Package Dependencies
# https://github.com/trycourier/courier-ios
```

On mobile, the SDK also needs native project setup before it renders: [iOS](https://www.courier.com/docs/sdk-libraries/ios#installation), [Android](https://www.courier.com/docs/sdk-libraries/android#installation), [Flutter](https://www.courier.com/docs/sdk-libraries/flutter#installation), and [React Native](https://www.courier.com/docs/sdk-libraries/react-native#installation).

### Authenticate and render

Call `signIn` with a `userId` and a JWT from your backend, then mount the inbox component.

```swift
import Courier_iOS

// Authenticate the user
await Courier.shared.signIn(userId: userId, accessToken: jwt)

// UIKit
view.addSubview(CourierInbox())

// SwiftUI
CourierInboxView()
```

## Verify

### Sign in and open the inbox

Sign in a user and open the screen that renders the inbox.

### Send a test message

[Send a message](https://www.courier.com/docs/in-app/send-to-the-inbox) to that user on the `inbox` channel.

### Confirm it appears

The message appears in the inbox in real time, and the unread count updates.

An inbox that stays empty usually has an expired or unscoped token. Check its `exp` and scopes with [Authenticate users](https://www.courier.com/docs/in-app/authenticate-users).
