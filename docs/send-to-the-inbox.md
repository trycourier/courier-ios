<!-- Generated from https://www.courier.com/docs/in-app/send-to-the-inbox by mintlify-docs. Edit the docs source, not this file. -->

# Send to the inbox

> Route a message to the inbox channel with the Send API, tag it for a tab with up to 9 tags of 30 characters each, and scope it to a tenant.

Source: https://www.courier.com/docs/in-app/send-to-the-inbox

A message reaches the inbox when you include `inbox` in its routing channels. The inbox is a channel like `email` or `push`, so the same [Send API](https://www.courier.com/docs/api-reference/send/send-a-message) call delivers to it.

Start with [Add an inbox](https://www.courier.com/docs/in-app/add-an-inbox) and [Authenticate users](https://www.courier.com/docs/in-app/authenticate-users) if your app doesn't show an inbox yet.

## Route a message to the inbox

This send references a published template with an In-App channel, so create one before you run it.

**Node.js**

```javascript
const response = await client.send.message({
  message: {
    to: { user_id: "user_123" },
    template: "nt_01kx4h2jdafq8bk9aftxak4b40",
    data: { name: "Sarah Bennett" },
    routing: { method: "single", channels: ["inbox"] },
  },
});

console.log(response.requestId);
```

**Python**

```python
response = client.send.message(
    message={
        "to": {"user_id": "user_123"},
        "template": "nt_01kx4h2jdafq8bk9aftxak4b40",
        "data": {"name": "Sarah Bennett"},
        "routing": {"method": "single", "channels": ["inbox"]},
    },
)
```

**cURL**

```bash
curl -X POST https://api.courier.com/send \
  -H "Authorization: Bearer $COURIER_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "message": {
      "to": { "user_id": "user_123" },
      "template": "nt_01kx4h2jdafq8bk9aftxak4b40",
      "data": { "name": "Sarah Bennett" },
      "routing": { "method": "single", "channels": ["inbox"] }
    }
  }'
```

**Ruby**

```ruby
response = courier.send_.message(
  message: {
    to: { user_id: "user_123" },
    template: "nt_01kx4h2jdafq8bk9aftxak4b40",
    data: { name: "Sarah Bennett" },
    routing: { method: "single", channels: ["inbox"] }
  }
)
```

**Go**

```go
response, err := client.Send.Message(context.TODO(), courier.SendMessageParams{
  Message: courier.SendMessageParamsMessage{
    To: courier.SendMessageParamsMessageToUnion{
      OfUserRecipient: &shared.UserRecipientParam{
        UserID: courier.String("user_123"),
      },
    },
    Template: courier.String("nt_01kx4h2jdafq8bk9aftxak4b40"),
    Data: map[string]any{"name": "Sarah Bennett"},
    Routing: courier.SendMessageParamsMessageRouting{
      Method: string(shared.MessageRoutingMethodSingle),
      Channels: []shared.MessageRoutingChannelUnionParam{
        {OfString: courier.String("inbox")},
      },
    },
  },
})
```

**Java**

```java
SendMessageParams.Message message = SendMessageParams.Message.builder()
    .to(SendMessageParams.Message.To.ofUserRecipient(
        UserRecipient.builder().userId("user_123").build()))
    .template("nt_01kx4h2jdafq8bk9aftxak4b40")
    .data(SendMessageParams.Message.Data.builder()
        .putAdditionalProperty("name", JsonValue.from("Sarah Bennett"))
        .build())
    .routing(SendMessageParams.Message.Routing.builder()
        .method(SendMessageParams.Message.Routing.Method.SINGLE)
        .channels(List.of(MessageRoutingChannel.ofString("inbox")))
        .build())
    .build();

SendMessageResponse response = client.send().message(
    SendMessageParams.builder().message(message).build());
```

**PHP**

```php
$response = $client->send->message(
  message: [
    'to' => ['userID' => "user_123"],
    'template' => "nt_01kx4h2jdafq8bk9aftxak4b40",
    'data' => ['name' => "Sarah Bennett"],
    'routing' => ['method' => "single", 'channels' => ["inbox"]],
  ],
);
```

**C#**

```csharp
var response = await client.Send.Message(new SendMessageParams
{
    Message = new Message
    {
        To = new To(new UserRecipient { UserID = "user_123" }),
        Template = "nt_01kx4h2jdafq8bk9aftxak4b40",
        Data = new Dictionary<string, JsonElement>
        {
            { "name", JsonSerializer.SerializeToElement("Sarah Bennett") }
        },
        Routing = new Routing
        {
            Method = Method.Single,
            Channels = new List<MessageRoutingChannel> { new MessageRoutingChannel("inbox") }
        }
    }
});
```

**CLI**

```bash
courier send message --message '{
  "to": { "user_id": "user_123" },
  "template": "nt_01kx4h2jdafq8bk9aftxak4b40",
  "data": { "name": "Sarah Bennett" },
  "routing": { "method": "single", "channels": ["inbox"] }
}'
```

**MCP**

```text
With Courier MCP, send my nt_01kx4h2jdafq8bk9aftxak4b40 template to user_123 on the inbox channel.
```

The inbox shows the template's **In-App** channel, so build that channel when you [design a template](https://www.courier.com/docs/design/templates/overview). For the send call itself, see [Send a message](https://www.courier.com/docs/send/overview).

The SDK receives everything in `data` with the message. Fields your template references (like `{{ name }}`) are interpolated. The rest passes through untouched, which is useful for deep linking to a screen when the user taps a message.

See [Add toasts](https://www.courier.com/docs/in-app/add-toasts).

## Tag a message for a tab

Inbox tabs filter on tags, and a message gets its tags from `metadata.tags` on the send. A tab defined with `filter: { tags: ["order"] }` shows the messages you tag here.

**Node.js**

```javascript
const response = await client.send.message({
  message: {
    to: { user_id: "user_123" },
    template: "nt_01kx4h2jdafq8bk9aftxak4b40",
    data: { name: "Sarah Bennett" },
    metadata: { tags: ["order"] },
    routing: { method: "single", channels: ["inbox"] },
  },
});
```

**Python**

```python
response = client.send.message(
    message={
        "to": {"user_id": "user_123"},
        "template": "nt_01kx4h2jdafq8bk9aftxak4b40",
        "data": {"name": "Sarah Bennett"},
        "metadata": {"tags": ["order"]},
        "routing": {"method": "single", "channels": ["inbox"]},
    },
)
```

**cURL**

```bash
curl -X POST https://api.courier.com/send \
  -H "Authorization: Bearer $COURIER_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "message": {
      "to": { "user_id": "user_123" },
      "template": "nt_01kx4h2jdafq8bk9aftxak4b40",
      "metadata": { "tags": ["order"] },
      "routing": { "method": "single", "channels": ["inbox"] }
    }
  }'
```

**Ruby**

```ruby
response = courier.send_.message(
  message: {
    to: { user_id: "user_123" },
    template: "nt_01kx4h2jdafq8bk9aftxak4b40",
    data: { name: "Sarah Bennett" },
    metadata: { tags: ["order"] },
    routing: { method: "single", channels: ["inbox"] }
  }
)
```

**Go**

```go
response, err := client.Send.Message(context.TODO(), courier.SendMessageParams{
  Message: courier.SendMessageParamsMessage{
    To: courier.SendMessageParamsMessageToUnion{
      OfUserRecipient: &shared.UserRecipientParam{
        UserID: courier.String("user_123"),
      },
    },
    Template: courier.String("nt_01kx4h2jdafq8bk9aftxak4b40"),
    Metadata: courier.SendMessageParamsMessageMetadata{
      Tags: []string{"order"},
    },
    Routing: courier.SendMessageParamsMessageRouting{
      Method: string(shared.MessageRoutingMethodSingle),
      Channels: []shared.MessageRoutingChannelUnionParam{
        {OfString: courier.String("inbox")},
      },
    },
  },
})
```

**Java**

```java
SendMessageParams.Message message = SendMessageParams.Message.builder()
    .to(SendMessageParams.Message.To.ofUserRecipient(
        UserRecipient.builder().userId("user_123").build()))
    .template("nt_01kx4h2jdafq8bk9aftxak4b40")
    .metadata(SendMessageParams.Message.Metadata.builder()
        .tags(List.of("order"))
        .build())
    .routing(SendMessageParams.Message.Routing.builder()
        .method(SendMessageParams.Message.Routing.Method.SINGLE)
        .channels(List.of(MessageRoutingChannel.ofString("inbox")))
        .build())
    .build();

SendMessageResponse response = client.send().message(
    SendMessageParams.builder().message(message).build());
```

**PHP**

```php
$response = $client->send->message(
  message: [
    'to' => ['userID' => "user_123"],
    'template' => "nt_01kx4h2jdafq8bk9aftxak4b40",
    'metadata' => ['tags' => ["order"]],
    'routing' => ['method' => "single", 'channels' => ["inbox"]],
  ],
);
```

**C#**

```csharp
var response = await client.Send.Message(new SendMessageParams
{
    Message = new Message
    {
        To = new To(new UserRecipient { UserID = "user_123" }),
        Template = "nt_01kx4h2jdafq8bk9aftxak4b40",
        Metadata = new() { Tags = ["order"] },
        Routing = new Routing
        {
            Method = Method.Single,
            Channels = new List<MessageRoutingChannel> { new MessageRoutingChannel("inbox") }
        }
    }
});
```

**CLI**

```bash
courier send message --message '{
  "to": { "user_id": "user_123" },
  "template": "nt_01kx4h2jdafq8bk9aftxak4b40",
  "metadata": { "tags": ["order"] },
  "routing": { "method": "single", "channels": ["inbox"] }
}'
```

**MCP**

```text
With Courier MCP, send my nt_01kx4h2jdafq8bk9aftxak4b40 template to user_123 on the inbox channel, tagged order.
```

A message carries at most 9 tags, and each tag is a string of up to 30 characters. Exceeding either limit fails the send with a validation error on `metadata.tags`.

Tags reach the client on every inbox message, so a custom UI can read them too. [Tabs and feeds](https://www.courier.com/docs/in-app/tabs-and-feeds) covers defining the tabs that filter on them.

## Expire a message

Set `message.expiry` to drop a message from the feed at a set time, such as a sale that ends tonight. Use `expires_in`, an ISO 8601 duration or milliseconds, or `expires_at`, an ISO 8601 timestamp. Set one of the two, not both.

```json
{
  "message": {
    "to": { "user_id": "user_123" },
    "template": "nt_01kx4h2jdafq8bk9aftxak4b40",
    "routing": { "method": "single", "channels": ["inbox"] },
    "expiry": { "expires_in": "P1D" }
  }
}
```

The `expires_in` clock starts when delivery starts, so a delayed send expires a day after it goes out, not a day after the call.

## Scope the inbox to a tenant

To show only one [tenant](https://www.courier.com/docs/tenants/overview)'s messages, pass `tenantId` at sign-in. You set it once on the client, and it applies to every component, every read, and the realtime connection. Without a `tenantId`, the inbox shows only messages sent without a tenant.

```swift
await Courier.shared.signIn(userId: userId, tenantId: "acme", accessToken: jwt)
```

Send to that tenant's inbox by setting `context.tenant_id` on the recipient. The message is visible only when the user signs in with the same tenant. (A bare `tenant_id` in `to`, with no `user_id`, fans out to every member of the tenant instead.)

**Node.js**

```javascript
await client.send.message({
  message: {
    to: { user_id: "user_123", context: { tenant_id: "acme" } },
    template: "nt_01kx4h2jdafq8bk9aftxak4b40",
    data: { name: "Sarah Bennett" },
    routing: { method: "single", channels: ["inbox"] },
  },
});
```

**Python**

```python
client.send.message(
    message={
        "to": {"user_id": "user_123", "context": {"tenant_id": "acme"}},
        "template": "nt_01kx4h2jdafq8bk9aftxak4b40",
        "data": {"name": "Sarah Bennett"},
        "routing": {"method": "single", "channels": ["inbox"]},
    },
)
```

**cURL**

```bash
curl -X POST https://api.courier.com/send \
  -H "Authorization: Bearer $COURIER_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "message": {
      "to": { "user_id": "user_123", "context": { "tenant_id": "acme" } },
      "template": "nt_01kx4h2jdafq8bk9aftxak4b40",
      "data": { "name": "Sarah Bennett" },
      "routing": { "method": "single", "channels": ["inbox"] }
    }
  }'
```

**Ruby**

```ruby
courier.send_.message(
  message: {
    to: { user_id: "user_123", context: { tenant_id: "acme" } },
    template: "nt_01kx4h2jdafq8bk9aftxak4b40",
    data: { name: "Sarah Bennett" },
    routing: { method: "single", channels: ["inbox"] }
  }
)
```

**Go**

```go
response, err := client.Send.Message(context.TODO(), courier.SendMessageParams{
  Message: courier.SendMessageParamsMessage{
    To: courier.SendMessageParamsMessageToUnion{
      OfUserRecipient: &shared.UserRecipientParam{
        UserID:  courier.String("user_123"),
        Context: shared.MessageContextParam{TenantID: courier.String("acme")},
      },
    },
    Template: courier.String("nt_01kx4h2jdafq8bk9aftxak4b40"),
    Data: map[string]any{"name": "Sarah Bennett"},
    Routing: courier.SendMessageParamsMessageRouting{
      Method: string(shared.MessageRoutingMethodSingle),
      Channels: []shared.MessageRoutingChannelUnionParam{
        {OfString: courier.String("inbox")},
      },
    },
  },
})
```

**Java**

```java
SendMessageParams.Message message = SendMessageParams.Message.builder()
    .to(SendMessageParams.Message.To.ofUserRecipient(
        UserRecipient.builder()
            .userId("user_123")
            .context(MessageContext.builder().tenantId("acme").build())
            .build()))
    .template("nt_01kx4h2jdafq8bk9aftxak4b40")
    .data(SendMessageParams.Message.Data.builder()
        .putAdditionalProperty("name", JsonValue.from("Sarah Bennett"))
        .build())
    .routing(SendMessageParams.Message.Routing.builder()
        .method(SendMessageParams.Message.Routing.Method.SINGLE)
        .channels(List.of(MessageRoutingChannel.ofString("inbox")))
        .build())
    .build();

client.send().message(SendMessageParams.builder().message(message).build());
```

**PHP**

```php
$client->send->message(
  message: [
    'to' => ['userID' => "user_123", 'context' => ['tenantID' => "acme"]],
    'template' => "nt_01kx4h2jdafq8bk9aftxak4b40",
    'data' => ['name' => "Sarah Bennett"],
    'routing' => ['method' => "single", 'channels' => ["inbox"]],
  ],
);
```

**C#**

```csharp
await client.Send.Message(new SendMessageParams
{
    Message = new Message
    {
        To = new To(new UserRecipient
        {
            UserID = "user_123",
            Context = new MessageContext { TenantID = "acme" }
        }),
        Template = "nt_01kx4h2jdafq8bk9aftxak4b40",
        Data = new Dictionary<string, JsonElement>
        {
            { "name", JsonSerializer.SerializeToElement("Sarah Bennett") }
        },
        Routing = new Routing
        {
            Method = Method.Single,
            Channels = new List<MessageRoutingChannel> { new MessageRoutingChannel("inbox") }
        }
    }
});
```

**CLI**

```bash
courier send message --message '{
  "to": { "user_id": "user_123", "context": { "tenant_id": "acme" } },
  "template": "nt_01kx4h2jdafq8bk9aftxak4b40",
  "data": { "name": "Sarah Bennett" },
  "routing": { "method": "single", "channels": ["inbox"] }
}'
```

**MCP**

```text
With Courier MCP, send my nt_01kx4h2jdafq8bk9aftxak4b40 template to user_123 in the acme tenant's inbox.
```

## FAQ

### Why is my inbox message not arriving?

Confirm all three:

- The environment has the Courier Inbox provider. It's already set up in production and test. Add it only in a custom environment or if it was deleted.
- The message routing includes `channels: ["inbox"]`.
- The recipient `user_id` matches the `userId` you [signed in with](https://www.courier.com/docs/in-app/authenticate-users).

### Can one user see different inboxes per tenant?

Sign in with a `tenantId` to scope the inbox to that tenant. Sign in again with a different `tenantId` to switch. The scope is client-level, not per-component. See [Scope the inbox to a tenant](https://www.courier.com/docs/in-app/send-to-the-inbox#scope-the-inbox-to-a-tenant).
