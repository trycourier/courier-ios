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

<table>
    <tr>
        <td>Status</td>
        <td>Response</td>
    </tr>
    <tr>
        <td>200</td>
        <td>

^ Extra blank line above!
```json
json
{
    "id": 10,
    "username": "alanpartridge",
    "email": "alan@alan.com",
    "password_hash": "$2a$10$uhUIUmVWVnrBWx9rrDWhS.CPCWCZsyqqa8./whhfzBZydX7yvahHS",
    "password_salt": "$2a$10$uhUIUmVWVnrBWx9rrDWhS.",
    "created_at": "2015-02-14T20:45:26.433Z",
    "updated_at": "2015-02-14T20:45:26.540Z"
}
```
V Extra blank line below!

        </td>
    </tr>
    <tr>
        <td>400</td>
        <td>

**Markdown** _here_. (Blank lines needed before and after!)

        </td>
    </tr>
</table>
