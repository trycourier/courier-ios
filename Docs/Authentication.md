# Authentication

Manages the current user and api keys between app sessions.

## Dependencies

<table>
    <thead>
        <tr>
            <th width="250px" align="left">Feature</th>
            <th width="750px" align="left">Reason</th>
        </tr>
    </thead>
    <tbody>
        <tr width="600px">
            <td align="left">
                <a href="https://github.com/trycourier/courier-ios/blob/feature/inbox-docs/Docs/Inbox.md">
                    <code>Courier Inbox</code>
                </a>
            </td>
            <td align="left">
                Needs authentication to view inbox messages that belong to a user.
            </td>
        </tr>
        <tr width="600px">
            <td align="left">
                <a href="https://github.com/trycourier/courier-ios/blob/feature/inbox-docs/Docs/PushNotifications.md">
                    <code>Push Notifications</code>
                </a>
            </td>
            <td align="left">
                Needs authentication to sync push notification device tokens to the current user and Courier.
            </td>
        </tr>
    </tbody>
</table>

&emsp;

# Usage

Put this code where you normally manage your user's state. The user's access to [`Courier Inbox`](https://github.com/trycourier/courier-ios/blob/feature/inbox-docs/Docs/Inbox.md) and [`Push Notifications`](https://github.com/trycourier/courier-ios/blob/feature/inbox-docs/Docs/PushNotifications.md) will automatically be managed by the SDK and stored in persistent storage. This means that if you user kills the app and start it back up, they will still be "signed in".

```swift
// Saves credentials locally and accesses the Courier API with them
// Uploads push notification devices tokens to Courier if needed
try await Courier.shared.signIn(
    accessToken: "pk_prod_H12...",
    clientKey: "YWQxN...",
    userId: "example_user_id"
)

// Removes the locally saved credentials
// Deletes push notification devices tokens to Courier if needed
try await Courier.shared.signOut()

// Other available properties
let userId = Courier.shared.userId
let isUserSignedIn = Courier.shared.isUserSignedIn
```

&emsp;

<table>
    <thead>
        <tr>
            <th width="250px" align="left">Property</th>
            <th width="750px" align="left">Details</th>
        </tr>
    </thead>
    <tbody>
        <tr width="600px">
            <td align="left">
                <code>accessToken</code>
            </td>
            <td align="left">
                A <a href="https://app.courier.com/settings/api-keys"><code>Courier API Key</code></a> or an <a href="https://www.courier.com/docs/reference/auth/issue-token/"><code>Access Token</code></a>. Here is more information about generating an <a href="https://github.com/trycourier/courier-ios/blob/feature/inbox-docs/Docs/PushNotifications.md"><code>Access Token</code></a>.
            </td>
        </tr>
        <tr width="600px">
            <td align="left">
                <code>clientKey</code>
            </td>
            <td align="left">
                The key required to make Courier Inbox work. You can find the key <a href="https://app.courier.com/channels/courier"><code>here</code></a>.
            </td>
        </tr>
        <tr width="600px">
            <td align="left">
                <code>userId</code>
            </td>
            <td align="left">
                The id of the user you want to read and write to. This likely will be the same as the <code>userId</code> you are already using, but can be different if you'd like. You can view the users in the Courier studio <a href="https://app.courier.com/users"><code>here</code></a>.
            </td>
        </tr>
    </tbody>
</table>

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

# Going to Production

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
