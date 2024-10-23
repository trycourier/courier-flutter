# Authentication

Manages user credentials between app sessions.

&emsp;

## SDK Features that need Authentication

<table>
    <thead>
        <tr>
            <th width="250px" align="left">Feature</th>
            <th width="750px" align="left">Reason</th>
        </tr>
    </thead>
    <tbody>
        <tr width="600px">
            <td align="left">
                <a href="https://github.com/trycourier/courier-flutter/blob/master/Docs/Inbox.md">
                    <code>Courier Inbox</code>
                </a>
            </td>
            <td align="left">
                Needs Authentication to view inbox messages that belong to a user.
            </td>
        </tr>
        <tr width="600px">
            <td align="left">
                <a href="https://github.com/trycourier/courier-flutter/blob/master/Docs/PushNotifications.md">
                    <code>Push Notifications</code>
                </a>
            </td>
            <td align="left">
                Needs Authentication to sync push notification device tokens to the current user and Courier.
            </td>
        </tr>
        <tr width="600px">
            <td align="left">
                <a href="https://github.com/trycourier/courier-flutter/blob/master/Docs/Preferences.md">
                    <code>Preferences</code>
                </a>
            </td>
            <td align="left">
                Needs Authentication to read and write to user notification preferences.
            </td>
        </tr>
    </tbody>
</table>

&emsp;

# Usage

Put this code where you normally manage your user's state. The user's access to [`Inbox`](https://github.com/trycourier/courier-flutter/blob/master/Docs/Inbox.md), [`Push Notifications`](https://github.com/trycourier/courier-flutter/blob/master/Docs/PushNotifications.md) and [`Preferences`](https://github.com/trycourier/courier-flutter/blob/master/Docs/Preferences.md) will automatically be managed by the SDK and stored in persistent storage. This means that if your user fully closes your app and starts it back up, they will still be "signed in".

```dart
await Courier.shared.signIn(
  userId: userId,
  accessToken: 'example', // Should be a Generated JWT but can be a Courier API key for testing. More info here: https://github.com/trycourier/courier-flutter/blob/master/Docs/Authentication.md#going-to-production
  clientKey: 'example', // Optional
  tenantId: 'example', // Optional
  showLogs: true, // Optional
);

await Courier.shared.signOut();

// Other available properties and functions

final userId = Courier.shared.userId
final isUserSignedIn = Courier.shared.isUserSignedIn

final listener = await Courier.shared.addAuthenticationListener { userId in
    print(userId ?? "No userId found")
}

await listener.remove()
```

&emsp;

<table>
    <thead>
        <tr>
            <th width="150px" align="left">Properties</th>
            <th width="450px" align="left">Details</th>
            <th width="400px" align="left">Where is this?</th>
        </tr>
    </thead>
    <tbody>
        <tr width="600px">
            <td align="left">
                <code>accessToken</code>
            </td>
            <td align="left">
                The key or token needed to authenticate requests to the Courier API.
            </td>
            <td align="left">
                For development only: <a href="https://app.courier.com/settings/api-keys"><code>authKey</code></a><br>
                For development or production: <a href="https://github.com/trycourier/courier-flutter/blob/master/Docs/Authentication.md#going-to-production"><code>accessToken</code></a>
            </td>
        </tr>
        <tr width="600px">
            <td align="left">
                <code>clientKey</code>
            </td>
            <td align="left">
                The key required to get <a href="https://github.com/trycourier/courier-flutter/blob/master/Docs/Inbox.md"><code>Courier Inbox</code></a> messages for the current user. Can be <code>nil</code> if you do not need Courier Inbox.
            </td>
            <td align="left">
                <a href="https://app.courier.com/channels/courier"><code>Courier Inbox clientKey</code></a>
            </td>
        </tr>
        <tr width="600px">
            <td align="left">
                <code>userId</code>
            </td>
            <td align="left">
                The id of the user you want to read and write to. This likely will be the same as the <code>userId</code> you are already using in your authentication system, but it can be different if you'd like.
            </td>
            <td align="left">
                You are responsible for this
            </td>
        </tr>
    </tbody>
</table>

&emsp;

# Going to Production

To create a production ready `accessToken`, call this:

```curl
curl --request POST \
     --url https://api.courier.com/auth/issue-token \
     --header 'Accept: application/json' \
     --header 'Authorization: Bearer $YOUR_AUTH_KEY' \
     --header 'Content-Type: application/json' \
     --data
 '{
    "scope": "user_id:$YOUR_USER_ID write:user-tokens inbox:read:messages inbox:write:events read:preferences write:preferences read:brands",
    "expires_in": "$YOUR_NUMBER days"
  }'
```

More Info: [`Courier Issue Token Docs`](https://www.courier.com/docs/reference/auth/issue-token/)
