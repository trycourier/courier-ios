<!-- Generated from https://www.courier.com/docs/sdk-libraries/ios by mintlify-docs. Edit the docs source, not this file. -->

# Courier iOS SDK

> Prebuilt inbox and preferences UI, push token sync, and Swift APIs for UIKit and SwiftUI. Install with Swift Package Manager on iOS 15 and up.

Source: https://www.courier.com/docs/sdk-libraries/ios

The Courier iOS SDK gives you prebuilt UI components and Swift APIs. It handles authentication, token management, and real-time message delivery.

This page is the iOS reference: what to install, how to configure Xcode, and the Swift API surface. Each flow is written once and applies to every platform.

| To do this | Read |
| :-- | :-- |
| Render the inbox | [Add an inbox](https://www.courier.com/docs/in-app/add-an-inbox?lang=iOS) |
| Theme it, handle taps, or build your own UI | [Customize the inbox](https://www.courier.com/docs/in-app/customize-the-inbox?lang=iOS) |
| Set up push, from provider to device | [Set up push notifications](https://www.courier.com/docs/guides/set-up-mobile-push) |
| Add the preference center | [Add a preference center](https://www.courier.com/docs/in-app/add-a-preference-center?lang=iOS) |
| Mint the JWT you sign in with | [Authenticate users](https://www.courier.com/docs/in-app/authenticate-users?lang=iOS) |

Available on
[GitHub](https://github.com/trycourier/courier-ios).

| Requirement | Value |
|-------------|-------|
| Min iOS version | 15.0 |
| Xcode | 16 or later |
| Swift | Your app can use the Swift 5 or Swift 6 language mode |
| Package managers | Swift Package Manager. CocoaPods up to 6.0.10. |

## Installation

In Xcode, go to **File > Add Package Dependencies**, paste `https://github.com/trycourier/courier-ios`, and pick **Up to Next Major Version**.

6.0.10 is the last version on CocoaPods. Newer versions ship through Swift Package Manager only.

## Authentication

Courier authenticates with a **JWT** that your backend mints with your Courier API key, never in client code. [Authenticate users](https://www.courier.com/docs/in-app/authenticate-users?lang=iOS) is the full guide: the token flow, scope strings, reading auth state, signing out, and token refresh. Using the EU datacenter? See [EU setup](https://www.courier.com/docs/in-app/authenticate-users?lang=iOS#connect-to-the-eu-datacenter).

Credentials persist across app sessions, so you sign in once per user rather than on every launch.

```swift
Task {
  await Courier.shared.signIn(userId: "your_user_id", accessToken: jwt)
  await Courier.shared.signOut()
}
```

## Inbox

[Add an inbox](https://www.courier.com/docs/in-app/add-an-inbox?lang=iOS) is the setup flow. These are the types it uses on iOS.

| Type | What it is |
| :-- | :-- |
| `CourierInboxView` | The prebuilt inbox as a SwiftUI view |
| `CourierInbox` | The same inbox as a UIKit view |
| `CourierInboxTheme` | Fonts, colors, unread indicators, swipe actions, button styles |
| `addInboxListener` | Raw message data and events, for a UI you render yourself |

Every callback and action these expose is documented per platform in [Data and actions](https://www.courier.com/docs/in-app/build-a-custom-inbox?lang=iOS#data-and-actions).

### Inbox theme

`CourierInboxTheme` is a constructor argument, and light and dark themes are separate.

```swift
CourierInboxView(
    canSwipePages: true,
    lightTheme: yourLightTheme,
    darkTheme: yourDarkTheme,
    ...
)
```

Branding from [Courier Studio](https://app.courier.com/content/brands) also applies. The SDK reads your brand's primary color.

## Push notifications

[Set up push notifications](https://www.courier.com/docs/guides/set-up-mobile-push) is the setup flow, from connecting APNs to a device that receives push. It covers the `CourierDelegate` wiring, `setAPNSToken` and `setToken`, permission, and reading the payload on tap.

> **Note:** The iOS Simulator receives push on a Mac with Apple silicon, including delivery and taps. Test on a physical device before you ship.

The one piece of configuration that lives here is the extension target.

### Notification Service Extension

iOS only wakes your app for a push while it is running, so delivery goes untracked when the app is closed. A Notification Service Extension runs instead, and reports the delivery for you.

#### Download the template

Download [`CourierNotificationServiceTemplate.zip`](https://github.com/trycourier/courier-notification-service-extension-template/archive/refs/heads/main.zip) and run `sh make_template.sh`.

#### Add the extension target

In Xcode: File > New > Target > select "Courier Service" > Finish.

#### Link the Courier SDK

Add the `Courier_iOS` library to the extension target. React Native and Flutter projects don't have the package yet, so add it first: **File > Add Package Dependencies**, paste `https://github.com/trycourier/courier-ios`, and pick **Up to Next Major Version**. If the extension has `pod 'Courier_iOS'` in your Podfile, remove it.

> **Note:** **Attach Mutable Content** must be on for the [APNs provider](https://www.courier.com/docs/integrations/push/apple-push-notification), or the extension never runs. It is on by default.

## Preferences

[Add a preference center](https://www.courier.com/docs/in-app/add-a-preference-center?lang=iOS) is the setup flow. These are the types it uses on iOS.

| Type | What it is |
| :-- | :-- |
| `CourierPreferencesView` | The prebuilt preference center as a SwiftUI view |
| `CourierPreferences` | The same view for UIKit |
| `mode` | `.topic` or `.channels([.push, .sms, .email])` |
| `CourierPreferencesTheme` | Fonts, colors, toggle styles, section headers |

> **Info:** Topics and sections are configured in the [Preferences Editor](https://www.courier.com/docs/guides/build-a-preference-center#configure-the-topics). See [Preferences Overview](https://www.courier.com/docs/recipients/preferences/overview) for how preference enforcement works at send time.

### Preferences theme

Light and dark themes are separate, and [Courier Studio branding](https://app.courier.com/content/brands) applies automatically when you supply a `brandId`.

## CourierClient

For advanced use cases, `CourierClient` is a low-level wrapper around the Courier API. Each client holds its own credentials, so you can spin up as many as you need.

### Initialization

```swift
let client = CourierClient(
    jwt:           "...",          // Optional. Required for most authenticated calls
    userId:        "your_user_id",
    connectionId:  "...",          // Optional. Used for the inbox websocket
    tenantId:      "...",          // Optional. Scopes the client to a tenant
    apiUrls:       .eu,            // Optional. Use for EU users
    showLogs:      true            // Optional. Defaults to your build configuration
)

// Inspect or log via the client
let options = client.options
client.log("...")
client.warn("...")
client.error("...")
```

### Token management

```swift
try await client.tokens.putUserToken(
    token: "...",
    provider: "firebase-fcm"
)

// Customize device metadata stored alongside the token
let device = CourierDevice(
    appId:         "APP_ID",
    adId:          "AD_ID",
    deviceId:      "DEVICE_ID",
    platform:      "ios",
    manufacturer:  "Apple",
    model:         "iPhone 15"
)

try await client.tokens.putUserToken(
    token: "...",
    provider: "firebase-fcm",
    device: device
)

try await client.tokens.deleteUserToken(token: "...")
```

### Inbox

```swift
let messages = try await client.inbox.getMessages(
    paginationLimit: 25,
    startCursor: nil
)

let archived = try await client.inbox.getArchivedMessages(
    paginationLimit: 25,
    startCursor: nil
)

let unreadCount = try await client.inbox.getUnreadMessageCount()

try await client.inbox.open(messageId: "...")
try await client.inbox.read(messageId: "...")
try await client.inbox.unread(messageId: "...")
try await client.inbox.archive(messageId: "...")
try await client.inbox.readAll()
```

### Inbox websocket

Receive real-time updates across devices:

```swift
let socket = client.inbox.socket

try await socket.connect(
    receivedMessage: { message in
        print(message)
    },
    receivedMessageEvent: { event in
        // Fires only when the event comes from a different connectionId
        // Available events: .read, .unread, .markAllRead, .opened, .archive
        print(event)
    }
)

try await socket.sendSubscribe()

await socket.disconnect()
```

### Preferences

```swift
let prefs = try await client.preferences.getUserPreferences(paginationCursor: nil)

let topic = try await client.preferences.getUserPreferenceTopic(topicId: "...")

try await client.preferences.putUserPreferenceTopic(
    topicId: "...",
    status: .optedIn,
    hasCustomRouting: true,
    customRouting: [.push]
)
```

### Branding

```swift
let brand = try await client.brands.getBrand(brandId: "...")
```

### URL tracking

Pass any tracking URL found inside a push notification payload or inbox message:

```swift
// Available events: .clicked, .delivered, .opened, .read, .unread
try await client.tracking.postTrackingUrl(
    url: "courier_tracking_url",
    event: .delivered
)
```

See the full Courier API reference at [courier.com/docs/reference](https://www.courier.com/docs/reference/api-overview).
