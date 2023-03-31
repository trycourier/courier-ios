# Testing

Common examples you use to send [`Courier Inbox`](https://github.com/trycourier/courier-ios/blob/feature/inbox-docs/Docs/Inbox.md) messages and [`Push Notifications`](https://github.com/trycourier/courier-ios/blob/feature/inbox-docs/Docs/PushNotifications.md) to your users.

&emsp;

# Courier Inbox



&emsp;

TODO Call out overrides with link

## Inbox Message

<table>
    <thead>
        <tr>
            <th width="500px" align="left">Swift Example</th>
            <th width="500px" align="left">Raw Curl</th>
        </tr>
    </thead>
    <tbody>
        <tr width="600px">
            <td align="left">
                <pre>
                    ```swift
                    import Courier_iOS

                    Task {
                            
                        // Sends a test message
                        // "YOUR_AUTH_KEY" is found here: https://app.courier.com/settings/api-keys
                        // DO NOT LEAVE "YOUR_AUTH_KEY" in your production app. This is only for testing.
                        try await Courier.shared.sendMessage(
                            authKey: "YOUR_AUTH_KEY",
                            userId: "example_user_id",
                            title: "Hello!",
                            message: "I hope you are having a great day",
                            providers: [.apns, .fcm]
                        )

                    }
                    ```
                </pre>
            </td>
            <td align="left">
                <pre>
                {
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
                }
                </pre>
            </td>
        </tr>
    </tbody>
</table>
