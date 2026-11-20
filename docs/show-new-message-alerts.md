<!-- Generated from https://www.courier.com/docs/in-app/add-toasts by mintlify-docs. Edit the docs source, not this file. -->

# Show an alert when a new inbox message arrives

> There is no built-in toast component on mobile. Listen for new inbox messages and show your own UI, or send a push notification.

Source: https://www.courier.com/docs/in-app/add-toasts

New-message alerts use the inbox's feed and [authentication](https://www.courier.com/docs/in-app/authenticate-users).

> **Note:** The built-in toast is web-only. On iOS, Android, Flutter, and React Native, listen for new messages and show your own UI. Or use [push notifications](https://www.courier.com/docs/integrations/push/apple-push-notification).

## Set up

Install the SDK for your framework:

```bash
# Xcode: File > Add Package Dependencies
# https://github.com/trycourier/courier-ios
```

On mobile, the SDK also needs native project setup before it renders: [iOS](https://www.courier.com/docs/sdk-libraries/ios#installation), [Android](https://www.courier.com/docs/sdk-libraries/android#installation), [Flutter](https://www.courier.com/docs/sdk-libraries/flutter#installation), and [React Native](https://www.courier.com/docs/sdk-libraries/react-native#installation).

Then [authenticate the user](https://www.courier.com/docs/in-app/authenticate-users) with the same `signIn` as the inbox. On mobile, listen for new messages and show your own UI:

```swift
// No built-in toast on iOS: listen for new messages and show your own UI
let listener = await Courier.shared.addInboxListener(
  onMessageEvent: { message, index, feed, event in
    // .added also fires when a message moves to Archived, so check the feed
    if event == .added && feed == .feed {
      showMyToast(message) // your own toast UI
    }
  }
)
```
