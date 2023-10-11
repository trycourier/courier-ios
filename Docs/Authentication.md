# Authentication

Manages user credentials between app sessions.

&emsp;

## SDK Features that need Authentication

<table>
    <thead>
        <tr>
            <th width="250px" align="left">Feature</th>
            <th width="800px" align="left">Reason</th>
        </tr>
    </thead>
    <tbody>
        <tr width="600px">
            <td align="left">
                <a href="https://github.com/trycourier/courier-ios/blob/master/Docs/Inbox.md">
                    <code>Courier Inbox</code>
                </a>
            </td>
            <td align="left">
                Needs Authentication to view inbox messages that belong to a user.
            </td>
        </tr>
        <tr width="600px">
            <td align="left">
                <a href="https://github.com/trycourier/courier-ios/blob/master/Docs/PushNotifications.md">
                    <code>Push Notifications</code>
                </a>
            </td>
            <td align="left">
                Needs Authentication to sync push notification device tokens to the current user and Courier.
            </td>
        </tr>
    </tbody>
</table>

&emsp;

# Usage

Put this code where you normally manage your user's state. The user's access to [`Courier Inbox`](https://github.com/trycourier/courier-ios/blob/master/Docs/Inbox.md) and [`Push Notifications`](https://github.com/trycourier/courier-ios/blob/master/Docs/PushNotifications.md) will automatically be managed by the SDK and stored in persistent storage. This means that if your user fully closes your app and starts it back up, they will still be "signed in".

```swift
import Courier_iOS

Task {

    // Saves credentials locally and accesses the Courier API with them
    // Uploads push notification devices tokens to Courier if needed
    try await Courier.shared.signIn(
        accessToken: "pk_prod_H12...",
        clientKey: "YWQxN...",
        userId: "example_user_id"
    )

    // Removes the locally saved credentials
    // Deletes the user's push notification device tokens in Courier if needed
    try await Courier.shared.signOut()

}

// Other available properties and functions

let userId = Courier.shared.userId
let isUserSignedIn = Courier.shared.isUserSignedIn

let listener = Courier.shared.addAuthenticationListener { userId in
    print(userId ?? "No userId found")
}

listener.remove()

```

&emsp;

<table>
    <thead>
        <tr>
            <th width="150px" align="left">Properties</th>
            <th width="450px" align="left">Details</th>
            <th width="450px" align="left">Where is this?</th>
        </tr>
    </thead>
    <tbody>
        <tr width="600px">
            <td align="left">
                <code>accessToken</code>
            </td>
            <td align="left">
                The key or token needed to authenticate requests to the Courier API.
            </td>
            <td align="left">
                For development only: <a href="https://app.courier.com/settings/api-keys"><code>authKey</code></a><br>
                For development or production: <a href="https://github.com/trycourier/courier-ios/blob/master/Docs/Authentication.md#going-to-production"><code>accessToken</code></a>
            </td>
        </tr>
        <tr width="600px">
            <td align="left">
                <code>clientKey</code>
            </td>
            <td align="left">
                The key required to get <a href="https://github.com/trycourier/courier-ios/blob/master/Docs/Inbox.md"><code>Courier Inbox</code></a> messages for the current user. Can be <code>nil</code> if you do not need Courier Inbox.
            </td>
            <td align="left">
                <a href="https://app.courier.com/channels/courier"><code>Courier Inbox clientKey</code></a>
            </td>
        </tr>
        <tr width="600px">
            <td align="left">
                <code>userId</code>
            </td>
            <td align="left">
                The id of the user you want to read and write to. This likely will be the same as the <code>userId</code> you are already using in your authentication system, but it can be different if you'd like.
            </td>
            <td align="left">
                You are responsible for this
            </td>
        </tr>
    </tbody>
</table>

&emsp;

# Going to Production

To create a production ready `accessToken`, call this:

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

More Info: [`Courier Issue Token Docs`](https://www.courier.com/docs/reference/auth/issue-token/)

This request should exist in a separate endpoint served by your backend.
