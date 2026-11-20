<!-- Generated from https://www.courier.com/docs/in-app/authenticate-users by mintlify-docs. Edit the docs source, not this file. -->

# Authenticate users with a JWT

> Mint a scoped JWT on your backend and sign the user in to any Courier client SDK, with the scope strings, token refresh, sign-out, and EU datacenter setup.

Source: https://www.courier.com/docs/in-app/authenticate-users

> **Info:** This is the auth model for every Courier client SDK. One sign-in covers Inbox, the preference center, and mobile push tokens.

Courier's client SDKs authenticate with a **JWT** (JSON Web Token). Your backend mints a short-lived, scoped token with your Courier API key, and the SDK signs the user in with it. Inbox reads these scopes. The preference center and mobile push each add their own. [Add an inbox](https://www.courier.com/docs/in-app/add-an-inbox) covers embedding the components first.

## How the JWT flow works

The private API key that signs a JWT stays on your server, so your backend mints every token, never client code:

### Your app calls your backend

When a user signs in, your app requests a token from [your backend](https://www.courier.com/docs/guides/add-an-inbox-to-nextjs) (for example, `GET /api/courier-jwt`).

### Your backend calls Courier

Your backend uses your [workspace API key](https://app.courier.com/settings/api-keys) to call the [Issue Token endpoint](https://www.courier.com/docs/api-reference/authentication/create-a-jwt) with the scopes the user needs. Keys are per [environment](https://www.courier.com/docs/workspaces/environments). Use the one matching the environment you're issuing tokens for.

### Your backend returns the JWT to the client

The client passes the token to the SDK through `signIn`, with the JWT as `accessToken`.

**Read the user ID from your backend's own authenticated session, never from the request body or a query parameter**. A caller who can name any user can mint a token for that user and read their inbox. This Next.js route handler reads the user with [Auth.js](https://authjs.dev) `auth()`. Swap in your own auth library's session call:

**app/api/courier/token/route.ts**

```tsx
import Courier from "@trycourier/courier";
import { auth } from "@/auth"; // your Auth.js config

export async function GET() {
  const client = new Courier({ apiKey: process.env.COURIER_API_KEY! });

  // Read the user from your own session. Never from the request.
  const session = await auth();
  if (!session) return new Response("Unauthorized", { status: 401 });

  const { token } = await client.auth.issueToken({
    scope: `user_id:${session.user.id} inbox:read:messages inbox:write:events`,
    expires_in: "1 day",
  });

  return Response.json({ userId: session.user.id, token });
}
```

## 1. Issue a token

Call [`POST /auth/issue-token`](https://www.courier.com/docs/api-reference/authentication/create-a-jwt) from [your backend](https://www.courier.com/docs/sdk-libraries/node) with your API key and a scope string:

**Node.js**

```javascript
const { token } = await client.auth.issueToken({
  scope: "user_id:user_123 inbox:read:messages inbox:write:events",
  expires_in: "2 days",
});
```

**Python**

```python
response = client.auth.issue_token(
    scope="user_id:user_123 inbox:read:messages inbox:write:events",
    expires_in="2 days",
)
```

**cURL**

```bash
curl --request POST \
  --url https://api.courier.com/auth/issue-token \
  --header "Authorization: Bearer $COURIER_API_KEY" \
  --header 'Content-Type: application/json' \
  --data '{
    "scope": "user_id:user_123 inbox:read:messages inbox:write:events",
    "expires_in": "2 days"
  }'
```

**Ruby**

```ruby
response = courier.auth.issue_token(
  scope: "user_id:user_123 inbox:read:messages inbox:write:events",
  expires_in: "2 days"
)
```

**Go**

```go
response, err := client.Auth.IssueToken(context.TODO(), courier.AuthIssueTokenParams{
  Scope:     "user_id:user_123 inbox:read:messages inbox:write:events",
  ExpiresIn: "2 days",
})
```

**Java**

```java
AuthIssueTokenParams params = AuthIssueTokenParams.builder()
    .scope("user_id:user_123 inbox:read:messages inbox:write:events")
    .expiresIn("2 days")
    .build();

var response = client.auth().issueToken(params);
```

**PHP**

```php
$response = $client->auth->issueToken(
    scope: 'user_id:user_123 inbox:read:messages inbox:write:events',
    expiresIn: '2 days',
);
```

**C#**

```csharp
var response = await client.Auth.IssueToken(new AuthIssueTokenParams
{
    Scope = "user_id:user_123 inbox:read:messages inbox:write:events",
    ExpiresIn = "2 days"
});
```

**CLI**

```bash
courier auth issue-token \
  --scope "user_id:user_123 inbox:read:messages inbox:write:events" \
  --expires-in "2 days"
```

**MCP**

```text
With Courier MCP, issue a two-day inbox token for user_123.
```

### Scopes

`scope` is one space-separated string. Copy the line for what you're building, and swap in your user's id.

> **Note:** **The `user_id` is yours, not Courier's.**
> Use whatever your app already calls this user, such as a database id or your auth provider's `sub`. Nothing has to exist in Courier first, since signing in registers the user. The same id goes in two places, `user_id:` in the scope and the `userId` you pass to `signIn`, and they have to match.

**Inbox and Toasts**

```text
user_id:user_123 inbox:read:messages inbox:write:events
```

**Add the preference center**

```text
user_id:user_123 inbox:read:messages inbox:write:events read:preferences write:preferences
```

**Add mobile push**

```text
user_id:user_123 inbox:read:messages inbox:write:events write:user-tokens
```

**Everything**

```text
user_id:user_123 inbox:read:messages inbox:write:events read:preferences write:preferences write:user-tokens read:brands
```

Every string starts with `user_id:` and the two inbox scopes. What each one grants:

| Scope | Grants |
| :-- | :-- |
| `user_id:user_123` | Binds the token to one user. Always required. |
| `inbox:read:messages` | Read the user's inbox messages. |
| `inbox:write:events` | Mark messages read, opened, archived. |
| `read:preferences` `write:preferences` | The embedded [preference center](https://www.courier.com/docs/in-app/add-a-preference-center). |
| `write:user-tokens` | Sync [push tokens](https://www.courier.com/docs/integrations/push/overview) from a mobile client. |
| `read:brands` | Apply a [brand](https://www.courier.com/docs/design/brands) to the rendered inbox. |

For every scope value, see the [`scope` parameter in the Issue Token API reference](https://www.courier.com/docs/api-reference/authentication/create-a-jwt#body-scope).

## 2. Sign in on the client

Signing in tells the SDK which user it is fetching messages for. Until it runs, the components render empty.

Pass the JWT to `signIn` when your app starts or the user logs in:

```swift
import Courier_iOS

// jwt is the token your backend issued in step 1
func authenticate() async {
  await Courier.shared.signIn(userId: userId, accessToken: jwt)
}
```

## 3. Read the signed-in user

Every platform exposes the current user and a listener that fires on sign-in and sign-out. Use the listener to clear app state on sign-out, or to re-render once credentials are restored on launch.

```swift
Task {
  let userId = await Courier.shared.userId
  let isSignedIn = await Courier.shared.isUserSignedIn

  let listener = await Courier.shared.addAuthenticationListener { userId in
    print(userId ?? "No user signed in")
  }

  listener.remove()
}
```

> **Note:** On mobile, credentials **persist across app sessions**. The SDK restores the last signed-in user on launch, so no cold start needs `signIn`. Call it again only when the user changes or the token expires.

## 4. Sign out

Call `signOut` when the user logs out of your app. It clears stored credentials, disconnects the real-time socket, and on mobile stops associating push tokens with that user.

```swift
Task {
  await Courier.shared.signOut()
}
```

## 5. Refresh tokens

Set `expires_in` to match your session length, and refresh the token before it expires so an open app [keeps loading messages](https://www.courier.com/docs/in-app/how-the-inbox-behaves).

The SDKs do **not** refresh tokens. Before the current token expires, mint a new JWT on your backend and call `signIn` again with it.

> **Warning:** `expires_in` is optional, and omitting it mints a token that **never expires**. Always set it. A leaked token with no `exp` grants that user's inbox forever. The only fix is rotating the API key that signed it.

## Connect to the EU datacenter

Every client SDK talks to Courier's **US** hosts by default. For a user whose notifications you send through the [EU datacenter](https://www.courier.com/docs/security/data-residency), pass EU URLs as `apiUrls` when you sign in:

```swift
await Courier.shared.signIn(
  userId: userId,
  accessToken: jwt,
  apiUrls: .eu
)
```

Creating a `CourierClient` yourself? Its constructor takes the same option:

```swift
let client = CourierClient(
  jwt: jwt,
  userId: userId,
  apiUrls: .eu
)
```

**Mint the JWT against the same region as the client.** For EU, your backend calls `https://api.eu.courier.com/auth/issue-token`. A US-issued token won't authenticate against EU hosts.

## Troubleshooting

**The inbox loads but shows no messages.** The connection succeeds either way, so check these four causes in order. Decode the JWT at [jwt.io](https://www.jwt.io) for the first three:

1. **`exp` is in the future.** An expired token returns an empty inbox. See [Refresh tokens](https://www.courier.com/docs/in-app/authenticate-users#5-refresh-tokens).
2. **`scope` includes `inbox:read:messages` and `inbox:write:events`.** Without them the connection succeeds and the feed is empty.
3. **The `user_id:` in the scope matches the `userId` you pass to `signIn`.** A mismatch reads an empty inbox belonging to whoever the token names.
4. **The `tenantId` matches the send.** A `tenantId` filters the feed, and the unread count, to that tenant. A message sent without a tenant, or in a different one, won't appear. Signing in without a `tenantId` shows only messages sent without a tenant. See [scope the inbox to a tenant](https://www.courier.com/docs/in-app/send-to-the-inbox#scope-the-inbox-to-a-tenant).

**Preferences editor is empty or read-only.** Add `read:preferences write:preferences` to the scope string.

**Push tokens never appear on the user.** Add `write:user-tokens` to the scope string. [Set up push notifications](https://www.courier.com/docs/guides/set-up-mobile-push#set-up-your-app) covers the registration that follows.

**Everything 401s for an EU user.** The token and the client must be in the same datacenter. Confirm your backend mints against `https://api.eu.courier.com/auth/issue-token` and the client passes EU [`apiUrls`](https://www.courier.com/docs/in-app/authenticate-users#connect-to-the-eu-datacenter).

## FAQ

### Why does the inbox connect but show no messages?

The token signed in but lacks read access. Confirm the [scope string](https://www.courier.com/docs/in-app/authenticate-users#scopes) includes `inbox:read:messages` and `inbox:write:events`, and that `exp` hasn't passed.
