- [Requirements](https://github.com/trycourier/courier-ios/tree/feature/inbox-docs#requirements)
- [Installation](https://github.com/trycourier/courier-ios/tree/feature/inbox-docs#installation)
- [Authentication](https://github.com/trycourier/courier-ios/blob/feature/inbox-docs/Docs/Authentication.md)
- [Inbox](https://github.com/trycourier/courier-ios/blob/feature/inbox-docs/Docs/Inbox.md)
- [Push Notifications](https://github.com/trycourier/courier-ios/blob/feature/inbox-docs/Docs/PushNotifications.md)
- [Testing](https://github.com/trycourier/courier-ios/blob/feature/inbox-docs/Docs/Testing.md)

# Authentication

```swift
let userId = Courier.shared.userId
let isUserSignedIn = Courier.shared.isUserSignedIn

try await Courier.shared.signIn(
    accessToken: "pk_prod_H12...",
    clientKey: "YWQxN...",
    userId: "example_user_id"
)

try await Courier.shared.signOut()
```

## **4. Managing User State**

Best user experience practice is to synchronize the current user's push notification tokens and the user's state. Courier does most of this for you automatically!

> You can use a Courier Auth Key [`found here`](https://app.courier.com/settings/api-keys) when developing.

> When you are ready for production release, you should be using a JWT as the `accessToken`.
> Here is more info about [`Going to Production`](#going-to-production)

Place these functions where you normally manage your user's state:
```swift
// Saves accessToken and userId to native level local storage
// This will persist between app sessions
await Courier.shared.signIn(
    accessToken: accessToken,
    userId: userId,
)

await Courier.shared.signOut()
```

## **Going to Production**

For security reasons, you should not keep your `authKey` (which looks like: `pk_prod_ABCD...`) in your production app. The `authKey` is safe to test with, but you will want to use an `accessToken` in production.

To create an `accessToken`, call this: 

```curl
curl --request POST \
     --url https://api.courier.com/auth/issue-token \
     --header 'Accept: application/json' \
     --header 'Authorization: Bearer $YOUR_AUTH_KEY' \
     --header 'Content-Type: application/json' \
     --data
 '{
    "scope": "user_id:$YOUR_USER_ID write:user-tokens",
    "expires_in": "$YOUR_NUMBER days"
  }'
```

Or generate one here:
[`Issue Courier Access Token`](https://www.courier.com/docs/reference/auth/issue-token/)

> This request to issue a token should likely exist in a separate endpoint served on your backend.

&emsp;
