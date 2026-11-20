<!-- Generated from https://www.courier.com/docs/in-app/how-the-inbox-behaves by mintlify-docs. Edit the docs source, not this file. -->

# Inbox runtime behavior

> Real-time updates, read and archive sync across devices, and message retention and expiry once a user is signed in, plus what to check when updates stop.

Source: https://www.courier.com/docs/in-app/how-the-inbox-behaves

## Real-time updates

Once a user signs in, the inbox opens a realtime connection. New messages appear live. Read, opened, and archived states sync across every device where that user is signed in.

The connection uses the same authenticated session, so a valid JWT is all it needs. The socket has no separate authentication.

The same live feed drives a custom UI. See [Custom UI](https://www.courier.com/docs/in-app/build-a-custom-inbox) to build your own inbox, with pagination, on any platform.

## Message retention

Courier keeps inbox messages for 1 year, including archived ones. A message sent with [`message.expiry`](https://www.courier.com/docs/in-app/send-to-the-inbox#expire-a-message) drops from the feed sooner, when that time passes. Read and archive states persist across sessions and devices.

## Troubleshooting

**Updates aren't live.** Check that the user is signed in with an unexpired JWT. An expired token ends the session, and no updates arrive until you sign in again with a fresh token. See [Authenticate users](https://www.courier.com/docs/in-app/authenticate-users).

**Custom UI shows stale data.** Read from the inbox listener and respond to its change events. Don't cache a one-time snapshot.
