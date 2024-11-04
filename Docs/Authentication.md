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
                    <code>Inbox</code>
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
        <tr width="600px">
            <td align="left">
                <a href="https://github.com/trycourier/courier-ios/blob/master/Docs/Preferences.md">
                    <code>Preferences</code>
                </a>
            </td>
            <td align="left">
                Needs Authentication to get and update notification preferences that belong to a user.
            </td>
        </tr>
    </tbody>
</table>

&emsp;

# Getting Started

Put this code where you normally manage your user's state. The user's access to [`Inbox`](https://github.com/trycourier/courier-ios/blob/master/Docs/Inbox.md), [`Push Notifications`](https://github.com/trycourier/courier-ios/blob/master/Docs/PushNotifications.md) and [`Preferences`](https://github.com/trycourier/courier-ios/blob/master/Docs/Preferences.md) will automatically be managed by the SDK and stored in persistent storage. This means that if your user fully closes your app and starts it back up, they will still be "signed in".

## 1. Generate a JWT

To generate a JWT, you will need to:
1. Create an endpoint on your backend
2. Call this function inside that endpoint: [`Generate Auth Tokens`](https://www.courier.com/docs/reference/auth/issue-token/)
3. Return the JWT

Here is a curl example with all the scopes needed that the SDK uses. Change the scopes to the scopes your need for your use case.

```curl
curl --request POST \
     --url https://api.courier.com/auth/issue-token \
     --header 'Accept: application/json' \
     --header 'Authorization: Bearer $YOUR_AUTH_KEY' \
     --header 'Content-Type: application/json' \
     --data
 '{
    "scope": "user_id:$YOUR_USER_ID write:user-tokens inbox:read:messages inbox:write:events read:preferences write:preferences read:brands",
    "expires_in": "$YOUR_NUMBER days"
  }'
```

## 2. Get a JWT

```swift
let userId = "your_user_id"
let jwt = await YourBackend.generateCourierJWT(for: userId)
```

## 3. Sign user in

Signed in users will stay signed in between app sessions.

```swift
let userId = "your_user_id"
await Courier.shared.signIn(accessToken: jwt, userId: userId)
```

If the token is expired, you get a new one from your endpoint and call `Courier.shared.signIn(...)` again.

## 4. Sign user out

This will remove any credentials that are stored between app sessions.

```swift
await Courier.shared.signOut()
```

## All Available Authentication Functions

```swift
let userId = Courier.shared.userId
let isUserSignedIn = Courier.shared.isUserSignedIn

let listener = Courier.shared.addAuthenticationListener { userId in
    print(userId ?? "No userId found")
}

listener.remove()
```
