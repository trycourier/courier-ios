# Courier Preferences

Allow users to update which types of notifications they would like to receive.

## Requirements

<table>
    <thead>
        <tr>
            <th width="300px" align="left">Requirement</th>
            <th width="750px" align="left">Reason</th>
        </tr>
    </thead>
    <tbody>
        <tr width="600px">
            <td align="left">
                <a href="https://github.com/trycourier/courier-ios/blob/master/Docs/Authentication.md">
                    <code>Authentication</code>
                </a>
            </td>
            <td align="left">
                Needed to view inbox messages that belong to a user.
            </td>
        </tr>
    </tbody>
</table>

&emsp;

# Get All User Preferences

Returns all the user's preferences. [`listAllUserPreferences`](https://www.courier.com/docs/reference/user-preferences/list-all-user-preferences/)

```swift
// paginationCursor is optional
let preferences = try await Courier.shared.getUserPreferences()
```

&emsp;

# Update Preference Topic

Updates a specific user preference topic. [`updateUserSubscriptionTopic`](https://www.courier.com/docs/reference/user-preferences/update-subscription-topic-preferences/)

```swift
try await Courier.shared.putUserPreferencesTopic(
    topicId: "9ADVWHD7Z1D4Q436SMECGDSDEWFA",
    status: .optedOut,
    hasCustomRouting: true,
    customRouting: [.sms, .push]
)
```

&emsp;

# Get Preference Topic

Gets a specific preference topic. [`getUserSubscriptionTopic`](https://www.courier.com/docs/reference/user-preferences/get-subscription-topic-preferences/

```swift
let topic = try await Courier.shared.getUserPreferencesTopic(
    topicId: "9ADVWHD7Z1D4Q436SMECGDSDEWFA"
)
```
