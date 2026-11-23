<!-- Generated from https://www.courier.com/docs/in-app/customize-the-inbox by mintlify-docs. Edit the docs source, not this file. -->

# Customize the inbox

> Theme the inbox for light and dark mode, and handle clicks, action clicks, and long presses.

Source: https://www.courier.com/docs/in-app/customize-the-inbox

The inbox ships with a default look and is fully themeable. [Add an inbox](https://www.courier.com/docs/in-app/add-an-inbox) covers embedding it first.

## Theme

Theme the inbox with a light and a dark `CourierInboxTheme`, as in the code below.

```swift
// UIKit
let inbox = CourierInbox(
  lightTheme: CourierInboxTheme(/* ... */),
  darkTheme: CourierInboxTheme(/* ... */)
)

// SwiftUI
CourierInboxView(
  lightTheme: CourierInboxTheme(/* ... */),
  darkTheme: CourierInboxTheme(/* ... */)
)
```

Full theme reference for each SDK: [iOS](https://www.courier.com/docs/sdk-libraries/ios#inbox-theme), [Android](https://www.courier.com/docs/sdk-libraries/android#inbox-theme), [Flutter](https://www.courier.com/docs/sdk-libraries/flutter#inbox-theme), and [React Native](https://www.courier.com/docs/sdk-libraries/react-native#inbox-theme).

## Handle interaction

Respond to interactions with your own callbacks instead of the SDK's default navigation. Every platform exposes the same two interactions:

- **Message click** fires when a user taps a message. Receives the `message` and its `index`.
- **Action click** fires when a user taps a message's action button. Receives the tapped `action` alongside the `message` and `index`.

```swift
// UIKit (CourierInbox) and SwiftUI (CourierInboxView) take the same callbacks
CourierInboxView(
  didClickInboxMessageAtIndex: { message, index in openInApp(message) },
  didClickInboxActionForMessageAtIndex: { action, message, index in handleAction(message, action) }
)
```

The callback names differ by platform but the payloads line up. On iOS, Android, Flutter, and React Native they are constructor arguments, view parameters, or setters, with positional arguments. **Action click passes the `action` first**, then the `message` and `index`.

### Long press

Every platform reports a long press, web included. It fires only on devices that send
touch events, so a desktop pointer never triggers it and you still need a click handler
for the same intent.

```swift
CourierInboxView(
  didLongPressInboxMessageAtIndex: { message, index in message.markAsArchived() }
)
```

The payload matches message click: an object on the web SDKs, positional arguments on mobile.

### Scroll

iOS and Android report the list's scroll offset, so you can shrink a header or hide a badge as the reader moves.

```swift
CourierInboxView(
  didScrollInbox: { scrollView in header.collapse(scrollView.contentOffset.y) }
)
```

The offset is a `UIScrollView` on iOS and a dp value on Android.

## Custom UI

Theming changes how the built-in inbox looks. To change what it renders, see [Build a custom inbox UI](https://www.courier.com/docs/in-app/build-a-custom-inbox). It covers both levels: replacing individual slots such as the list item or header, and reading the message data and actions to build the UI yourself.

## FAQ

### How do I match the inbox to my brand?

Supply light and dark `CourierInboxTheme` values and set colors, typography, and spacing there. See [Theme](https://www.courier.com/docs/in-app/customize-the-inbox#theme) and your platform's SDK reference for the full field list.

### Can I render my own message rows?

See [Custom UI](https://www.courier.com/docs/in-app/customize-the-inbox#custom-ui): replace parts of the built-in inbox on the web SDKs, or build the whole UI yourself on any platform.

### What is the difference between replacing parts and building my own UI?

[Building your own UI](https://www.courier.com/docs/in-app/build-a-custom-inbox#build-your-own-ui) replaces the whole thing and works on every platform, including mobile.

### Can I replace parts of the inbox on mobile?

Not yet, that is a web-SDK feature. On mobile, theme the built-in component or [build your own UI](https://www.courier.com/docs/in-app/build-a-custom-inbox#build-your-own-ui) from the listener.

### Do I still get real-time sync with a custom UI?

The SDK keeps the feed synced and calls your renderer or listener on every change. See [How the inbox behaves](https://www.courier.com/docs/in-app/how-the-inbox-behaves).
