# Testing

Common examples for testing [`Courier Inbox`](https://github.com/trycourier/courier-ios/blob/master/Docs/Inbox.md) and [`Push Notifications`](https://github.com/trycourier/courier-ios/blob/master/Docs/PushNotifications.md)

&emsp;

## Requirements

<table>
    <thead>
        <tr>
            <th width="300px" align="left">Requirement</th>
            <th width="700px" align="left">Reason</th>
        </tr>
    </thead>
    <tbody>
        <tr width="600px">
            <td align="left">
                <a href="https://app.courier.com/settings/api-keys">
                    <code>Authentication Key</code>
                </a>
            </td>
            <td align="left">
                Needed to authenticate your HTTP requests to the Courier <a href="https://www.courier.com/docs/reference/send/message/"><code>/send</code></a> api
            </td>
        </tr>
    </tbody>
</table>

⚠️ Only use your `Authentication Key` while testing. For security reasons, Courier does not recommend you leave this key in your production app. More info can be found [`here`](https://github.com/trycourier/courier-ios/blob/master/Docs/Authentication.md#usage).

&emsp;

## Courier Inbox Message

[`Courier Inbox`](https://github.com/trycourier/courier-ios/blob/master/Docs/Inbox.md) must be setup to receive messages.

```bash
curl --request POST \
  --url https://api.courier.com/send \
  --header 'Authorization: Bearer YOUR_AUTH_KEY' \
  --header 'Content-Type: application/json' \
  --data '{
  "message": {
    "to": [
      {
        "user_id": "YOUR_USER_ID"
      }
    ],
    "content": {
      "version": "2020-01-01",
      "body": "Lorem ipsum dolor sit amet",
      "title": "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod",
      "elements": [
        {
          "type": "action",
          "data": {
            "CUSTOM_KEY": "YOUR_CUSTOM_VALUE"
          },
          "content": "Button 1"
        }
      ]
    },
    "data": {
      "CUSTOM_INBOX_MESSAGE_KEY": "YOUR_CUSTOM_VALUE"
    },
    "routing": {
      "channels": [
        "inbox"
      ],
      "method": "all"
    }
  }
}'
```

## Push Notification - Apple Push Notification Service (APNS)

[`Push Notifications`](https://github.com/trycourier/courier-ios/blob/master/Docs/PushNotifications.md) must be setup to receive messages.

⚠️ Courier automatically applies some overrides. View the overrides [`here`](https://app.courier.com/channels/apn).

```bash
curl --request POST \
  --url https://api.courier.com/send \
  --header 'Authorization: Bearer YOUR_AUTH_KEY' \
  --header 'Content-Type: application/json' \
  --data '{
  "message": {
    "to": [
      {
        "user_id": "YOUR_USER_ID"
      }
    ],
    "content": {
      "title": "Lorem ipsum dolor sit amet",
      "body": "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod"
    },
    "routing": {
      "channels": [
        "apn"
      ],
      "method": "all"
    },
    "providers": {
      "apn": {
        "override": {
          "body": {
            "aps": {
              "alert": {
                "title": "Lorem ipsum dolor sit amet",
                "body": "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod"
              },
              "badge": 123,
              "sound": "ping.aiff",
              "CUSTOM_NUMBER": 456,
              "CUSTOM_KEY": "YOUR_CUSTOM_VALUE",
              "CUSTOM_BOOLEAN": true
            }
          }
        }
      }
    }
  }
}'
```

## Push Notification - Firebase Cloud Messaging (FCM)

[`Push Notifications`](https://github.com/trycourier/courier-ios/blob/master/Docs/PushNotifications.md) must be setup to receive messages.

⚠️ Courier automatically applies some overrides. View the overrides [`here`](https://app.courier.com/channels/firebase-fcm).
```bash
curl --request POST \
  --url https://api.courier.com/send \
  --header 'Authorization: Bearer YOUR_AUTH_KEY' \
  --header 'Content-Type: application/json' \
  --data '{
  "message": {
    "to": [
      {
        "user_id": "YOUR_USER_ID"
      }
    ],
    "content": {
      "title": "Lorem ipsum dolor sit amet",
      "body": "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod"
    },
    "routing": {
      "channels": [
        "firebase-fcm"
      ],
      "method": "all"
    },
    "providers": {
      "firebase-fcm": {
        "override": {
          "body": {
            "apns": {
              "payload": {
                "aps": {
                  "badge": 123,
                  "sound": "ping.aiff",
                  "APNS_CUSTOM_KEY": "YOUR_CUSTOM_VALUE",
                  "APNS_CUSTOM_BOOLEAN": true,
                  "APNS_CUSTOM_NUMBER": 456
                }
              }
            },
            "data": {
              "FCM_CUSTOM_KEY": "YOUR_CUSTOM_VALUE"
            }
          }
        }
      }
    }
  }
}'
```
