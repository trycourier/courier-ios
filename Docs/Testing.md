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
                Test
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
