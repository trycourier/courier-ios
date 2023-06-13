# Testing

<<<<<<< HEAD
Common examples for testing [`Courier Inbox`](https://github.com/trycourier/courier-ios/blob/master/Docs/Inbox.md) and [`Push Notifications`](https://github.com/trycourier/courier-ios/blob/master/Docs/PushNotifications.md)
=======
Common examples you can use to send [`Courier Inbox`](https://github.com/trycourier/courier-ios/blob/master/Docs/Inbox.md) messages and [`Push Notifications`](https://github.com/trycourier/courier-ios/blob/master/Docs/PushNotifications.md) to your users.
>>>>>>> d935a39 (Clean up)

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

<<<<<<< HEAD
⚠️ Only use your `Authentication Key` while testing. For security reasons, Courier does not recommend you leave this key in your production app. More info can be found [`here`](https://github.com/trycourier/courier-ios/blob/master/Docs/Authentication.md#usage).

=======
>>>>>>> d935a39 (Clean up)
&emsp;

## Courier Inbox Message

[`Courier Inbox`](https://github.com/trycourier/courier-ios/blob/master/Docs/Inbox.md) must be setup to receive messages.

<<<<<<< HEAD
=======
<table>
<tr>
<td width="500px" align="left">Swift</td>
<td width="500px" align="left">HTTP</td>
</tr>
<tr width="600px">
<td> 

```swift
try await Courier.shared.sendMessage(
    authKey: "YOUR_AUTH_KEY",
    userId: "example_user_id",
    title: "Hey there 👋",
    message: "Have a great day 😁",
    providers: [.inbox]
)
```

</td>
<td>

>>>>>>> d935a39 (Clean up)
```bash
curl --request POST \
  --url https://api.courier.com/send \
  --header 'Authorization: Bearer YOUR_AUTH_KEY' \
  --header 'Content-Type: application/json' \
  --data '{
<<<<<<< HEAD
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

=======
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

### Result

<img width="471" alt="inbox-example" src="https://user-images.githubusercontent.com/6370613/232109373-2e309171-fdb1-41f1-9652-c8a12c6f9d58.png">

&emsp;

>>>>>>> d935a39 (Clean up)
## Push Notification - Apple Push Notification Service (APNS)

[`Push Notifications`](https://github.com/trycourier/courier-ios/blob/master/Docs/PushNotifications.md) must be setup to receive messages.

⚠️ Courier automatically applies some overrides. View the overrides [`here`](https://app.courier.com/channels/apn).

<<<<<<< HEAD
=======
<table>
<tr>
<td width="500px" align="left">Swift</td>
<td width="500px" align="left">HTTP</td>
</tr>
<tr width="600px">
<td> 

```swift
try await Courier.shared.sendMessage(
    authKey: "YOUR_AUTH_KEY",
    userId: "example_user_id",
    title: "Hey there 👋",
    message: "Have a great day 😁",
    providers: [.apns]
)
```

</td>
<td>

>>>>>>> d935a39 (Clean up)
```bash
curl --request POST \
  --url https://api.courier.com/send \
  --header 'Authorization: Bearer YOUR_AUTH_KEY' \
  --header 'Content-Type: application/json' \
  --data '{
<<<<<<< HEAD
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

=======
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
                "apn"
            ]
        }
    }
}'
```

</td>
</tr>
</table>

### Result

<img width="894" alt="apns-push" src="https://user-images.githubusercontent.com/6370613/229195948-1b49b58e-8f38-4fd3-ab6b-7e3844def61d.png">

&emsp;

>>>>>>> d935a39 (Clean up)
## Push Notification - Firebase Cloud Messaging (FCM)

[`Push Notifications`](https://github.com/trycourier/courier-ios/blob/master/Docs/PushNotifications.md) must be setup to receive messages.

⚠️ Courier automatically applies some overrides. View the overrides [`here`](https://app.courier.com/channels/firebase-fcm).
<<<<<<< HEAD
=======

<table>
<tr>
<td width="500px" align="left">Swift</td>
<td width="500px" align="left">HTTP</td>
</tr>
<tr width="600px">
<td> 

```swift
try await Courier.shared.sendMessage(
    authKey: "YOUR_AUTH_KEY",
    userId: "example_user_id",
    title: "Hey there 👋",
    message: "Have a great day 😁",
    providers: [.fcm]
)
```

</td>
<td>

>>>>>>> d935a39 (Clean up)
```bash
curl --request POST \
  --url https://api.courier.com/send \
  --header 'Authorization: Bearer YOUR_AUTH_KEY' \
  --header 'Content-Type: application/json' \
  --data '{
<<<<<<< HEAD
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
=======
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
                "firebase-fcm"
            ]
        }
    }
}'
```

</td>
</tr>
</table>

### Result

<img width="894" alt="apns-push" src="https://user-images.githubusercontent.com/6370613/229195948-1b49b58e-8f38-4fd3-ab6b-7e3844def61d.png">
>>>>>>> d935a39 (Clean up)
