# `CourierClient`

Base layer Courier API wrapper.

## Initialization

Creating a client stores request authentication credentials only for that specific client. You can create as many clients as you'd like. See the "Going to Production" section <a href="https://github.com/trycourier/courier-ios/blob/master/Docs/Authentication.md#going-to-production"><code>here</code></a> for more info.

```swift
// Creating a client
let client = CourierClient(
    jwt:           "...",          // Optional. Likely needed for your use case. See above for more authentication details
    clientKey:     "...",          // Optional. Used only for Inbox
    userId:        "your_user_id",
    connectionId:  "...",          // Optional. Used for inbox websocket
    tenantId:      "...",          // Optional. Used for scoping a client to a specific tenant
    showLogs:      ..              // Optional. Defaults to your current BuildConfig
)

// Details about the client
let options = client.options

// Logging to the console
client.log("...")
client.warn("...")
client.error("...")
```

## Token Management APIs

All available APIs for Token Management

```swift
// Saves a token into Courier Token Management
try await client.tokens.putUserToken(
    token: "...",
    provider: "firebase-fcm"
)

// To customize the device of the token being saved
let device = CourierDevice(
    app_id:        "APP_ID",    // Optional
    ad_id:         "AD_ID",     // Optional
    device_id:     "DEVICE_ID", // Optional
    platform:      "ios",       // Optional
    manufacturer:  "Apple",     // Optional
    model:         "iPhone 123" // Optional
)

// Alternatively, you can use CourierDevice.current to get what
// the Courier SDK can find about the current device being used
// CourierDevice() is the default param

try await client.tokens.putUserToken(
    token: "...",
    provider: "firebase-fcm",
    device: device // Optional
)

// Deletes the token from Courier Token Management
try await client.tokens.deleteUserToken(
    token: "..."
)
```

## Inbox APIs

All available APIs for Inbox

```swift
// Get all inbox messages
// Includes the total count in the response
let messages = try await client.inbox.getMessages(
    paginationLimit: 123, // Optional
    startCursor: nil      // Optional
)

// Returns only archived messages
// Includes the total count of archived message in the response
let archivedMessages = try await client.inbox.getArchivedMessages(
    paginationLimit: 123, // Optional
    startCursor: null     // Optional
)

// Gets the number of unread messages
let unreadCount = client.inbox.getUnreadMessageCount()

// Tracking messages
client.inbox.open(messageId = "...")
client.inbox.read(messageId = "...")
client.inbox.unread(messageId = "...")
client.inbox.archive(messageId = "...")
client.inbox.readAll()

// Inbox Websocket
let socket = client.inbox.socket

socket.onOpen = {
    print("Socket Opened")
}

socket.onClose = { code, reason in
    print("Socket closed: \(code), \(String(describing: reason))")
}

socket.onError = { error in
    print(error)
}

// Returns the event received
// Note: This will not fire unless you provide a connectionId to the client and the event comes from another app using a different connectionId
// Available events: .read, .unread, .markAllRead, .opened,.archive
socket.receivedMessageEvent = { event in
    print(event)
}

socket.receivedMessage = { message in
    print(message)
}

try await socket.connect() // Connects the socket
try await socket.sendSubscribe() // Subscribes to socket events for the user id in the client

socket.disconnect() // Disconnects the socket
```

## Preferences APIs

All available APIs for Preferences

```swift
// Get all the available preference topics
let preferences = try await client.preferences.getUserPreferences(
    paginationCursor: nil // Optional
)

// Gets a specific preference topic
let topic = try await client.preferences.getUserPreferenceTopic(
    topicId: "..."
)

// Updates a user preference topic
try await client.preferences.putUserPreferenceTopic(
    topicId: "...",
    status: .optedIn,
    hasCustomRouting: true,
    customRouting: [.push]
)
```

## Branding APIs

All available APIs for Branding

```swift
let brandRes = try await client.brands.getBrand(
    brandId: "..."
)
```

## URL Tracking APIs

All available APIs for URL Tracking

```swift
// Pass a trackingUrl, usually found inside of a push notification payload or Inbox message
// Tell which event happened. 
// All available events: .clicked, .delivered, .opened, .read, .unread
try await client.tracking.postTrackingUrl(
    url: "courier_tracking_url",
    event: .delivered
)
