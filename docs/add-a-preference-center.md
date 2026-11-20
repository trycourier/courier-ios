<!-- Generated from https://www.courier.com/docs/in-app/add-a-preference-center by mintlify-docs. Edit the docs source, not this file. -->

# Add a preference center

> Embed the Courier Preferences component so users pick their topics and channels, with the JWT scopes it needs, mobile display modes.

Source: https://www.courier.com/docs/in-app/add-a-preference-center

Courier Preferences is an embeddable UI where a signed-in user picks the topics they receive and how each is delivered. It uses the same SDKs and `signIn` as the inbox. If you already have the inbox, preferences is one more component.

> **Warning:** The component renders empty unless the user's JWT has `read:preferences write:preferences` in its scope string, as [Authenticate users](https://www.courier.com/docs/in-app/authenticate-users) covers.

## Set up

Install the SDK for your framework:

```bash
# Xcode: File > Add Package Dependencies
# https://github.com/trycourier/courier-ios
```

On mobile, the SDK also needs native project setup before it renders: [iOS](https://www.courier.com/docs/sdk-libraries/ios#installation), [Android](https://www.courier.com/docs/sdk-libraries/android#installation), [Flutter](https://www.courier.com/docs/sdk-libraries/flutter#installation), and [React Native](https://www.courier.com/docs/sdk-libraries/react-native#installation).

Then [authenticate the user](https://www.courier.com/docs/in-app/authenticate-users) and render the preferences component:

```swift
// Use CourierPreferences (UIKit) or CourierPreferencesView (SwiftUI).
// Both take a display mode; see the SDK reference for the options.
import Courier_iOS

// UIKit
view.addSubview(CourierPreferences(mode: .channels(CourierUserPreferencesChannel.allCases)))

// SwiftUI
CourierPreferencesView(mode: .channels(CourierUserPreferencesChannel.allCases))
```

## Choose a display mode

The mobile components take a `mode` that sets how much control the user gets:

- **Topic mode**: one on/off toggle per subscription topic. The simplest option, and the usual choice.
- **Channels mode**: per-channel controls within each topic, so a user can keep a topic but receive it by email only.

```swift
CourierPreferencesView(mode: .topic)
CourierPreferencesView(mode: .channels([.push, .sms, .email]))
```

You configure topics and sections in the [preference center editor](https://www.courier.com/docs/guides/build-a-preference-center#configure-the-topics). For how Courier enforces these choices at send time, see [how preferences resolve](https://www.courier.com/docs/recipients/preferences/overview).

## Verify

### Sign in with preference scopes

Sign in a user whose JWT includes `read:preferences write:preferences`.

### Open the preferences screen

Open the screen that renders the preferences component.

### Confirm topics persist

Your workspace's preference topics appear, and toggling one persists after a reload.
