# Testing

Common examples you use to send [`Courier Inbox`](https://github.com/trycourier/courier-ios/blob/feature/inbox-docs/Docs/Inbox.md) messages and [`Push Notifications`](https://github.com/trycourier/courier-ios/blob/feature/inbox-docs/Docs/PushNotifications.md) to your users.

&emsp;

# Courier Inbox



&emsp;

TODO Call out overrides with link

<table>
    <thead>
        <tr>
            <th width="300px" align="left">Message</th>
            <th width="700px" align="left">Expectation</th>
        </tr>
    </thead>
    <tbody>
        <tr width="600px">
            <td align="left">
                <a href="TODO">
                    <code>Simple Inbox Message</code>
                </a>
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
        <tr width="600px">
            <td align="left">
                <a href="TODO">
                    <code>Inbox Message + Actions</code>
                </a>
            </td>
            <td align="left">
                Lorem ipsum dolor
            </td>
        </tr>
        <tr width="600px">
            <td align="left">
                <a href="TODO">
                    <code>APNS Push Notification</code>
                </a>
            </td>
            <td align="left">
                Lorem ipsum dolor
            </td>
        </tr>
        <tr width="600px">
            <td align="left">
                <a href="TODO">
                    <code>APNS Push Notification + Custom Data & iOS App Icon Badge</code>
                </a>
            </td>
            <td align="left">
                Lorem ipsum dolor
            </td>
        </tr>
        <tr width="600px">
            <td align="left">
                <a href="TODO">
                    <code>FCM Push Notification</code>
                </a>
            </td>
            <td align="left">
                Lorem ipsum dolor
            </td>
        </tr>
        <tr width="600px">
            <td align="left">
                <a href="TODO">
                    <code>FCM Push Notification + Custom Data & iOS App Icon Badge</code>
                </a>
            </td>
            <td align="left">
                Lorem ipsum dolor
            </td>
        </tr>
    </tbody>
</table>

## Inbox Message

TODO
