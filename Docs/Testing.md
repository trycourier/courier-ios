# Testing

Common examples you use to send [`Courier Inbox`](https://github.com/trycourier/courier-ios/blob/feature/inbox-docs/Docs/Inbox.md) messages and [`Push Notifications`](https://github.com/trycourier/courier-ios/blob/feature/inbox-docs/Docs/PushNotifications.md) to your users.

&emsp;

# Courier Inbox



&emsp;

TODO Call out overrides with link

## Inbox Message


<table>
<tr>
<td width="500px" align="left">Swift</td>
<td width="500px" align="left">JSON</td>
</tr>
<tr width="600px">
<td> 

```swift
try await Courier.shared.sendMessage(
    authKey: "YOUR_AUTH_KEY",
    userId: "example_user_id",
    title: "Hello!",
    message: "I hope you are having a great day",
    providers: [.apns, .fcm]
)
```

</td>
<td>

```curl
curl --request POST \
  --url https://api.courier.com/send \
  --header 'Authorization: Bearer YOUR_AUTH_KEY' \
  --header 'Content-Type: application/json' \
  --data '{
    "message": {
        "to": {
            "user_id": "example_user_id"
        },
        "content": {
            "title": "Hey there 👋",
            "body": "Have a great day 😁"
        },
        "routing": {
            "method": "all",
            "channels": [
                "inbox"
            ]
        }
    }
}'
```

</td>
</tr>
</table>
