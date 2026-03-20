# GuardLink Network API

---

## Header: `network`
*Network related requests.*

---

### `discovery`
Broadcast to find available GuardLink servers.

**Request**
```lua
{ action = "discovery" }
```

**Response (success)**
```lua
{
    action = "discovery",
    name = "NATION_NAME",
    key = { shared = "...", public = "..." },
    certificate = {
        signature = "...",
        issuedAt = "...",
        issuedAtEpoch = 0,
        publicKey = "...",
        shared = "..."
    }
}
```

---

### `heartbeat`
Sent automatically by the client API in response to a server heartbeat. Not called manually.

---

### `ping`
Measure latency. Works authenticated or unauthenticated.

**Request**
```lua
{ action = "ping" }
```

**Response**
```lua
{
    action = "ping",
    timestamp = 0  -- server epoch (utc) at time of response
}
```

---

### `disconnect`
Close the session. Sent automatically by `api.disconnect()`.

---

## Header: `account`
*Login and register are plaintext with partial encryption (see below). All other actions are AES encrypted and require an active session.*

---

### `login`
Authenticate and open a session. Handled by `api.auth()`, do not call manually.

**Request**
```lua
{
    action = "login",
    username = { cipher = "...", iv = {...} },  -- AES encrypted
    password = { cipher = "...", iv = {...} },   -- AES encrypted
    key = { cipher = "..." }                     -- RSA encrypted AES keyStr
}
```

**Response (success)**
```lua
{
    action = "login",
    status = "success",
    token = "...",
    channel = 0,
    clientID = "..."
}
```

**Response (failure)**
```lua
{
    action = "login",
    status = "failure",
    error = "..."  -- INVALID_CREDENTIALS, ACCOUNT_NOT_FOUND, etc.
}
```

---

### `register`
Create a new account. Handled by `api.createAccount()`, do not call manually.

**Request**
```lua
{
    action = "register",
    username = { cipher = "...", iv = {...} },    -- AES encrypted
    password = { cipher = "...", iv = {...} },    -- AES encrypted
    key = { cipher = "..." },                     -- RSA encrypted AES keyStr
    invite_code = { cipher = "...", iv = {...} }  -- AES encrypted, only if server is invite-only
}
```

**Response (success)**
```lua
{
    action = "register",
    status = "success"
}
```

**Response (failure)**
```lua
{
    action = "register",
    status = "failure",
    error = "..."  -- ACCOUNT_EXISTS, ACCOUNT_INVALID_CHAR, MISSING_INVITE_CODE, UNKNOWN_INVITE_CODE, etc.
}
```

---

### `info`
Request account data. Requires session. Requesting another account requires either nation consent >= 1.0 or the `accounts.view_others` permission.

**Request**
```lua
{
    action = "info",
    token = "...",
    name = "accountName"
}
```

**Response (success)**
```lua
{
    action = "info",
    status = "success",
    data = {
        name = "...",
        uuid = "...",
        creationDate = "...",
        creationTime = "...",
        role = "...",
        ban = { active = false, startTime = nil, duration = 0, reason = "" },
        wallets = {}
    }
}
```

**Response (failure)**
```lua
{
    action = "info",
    status = "failure",
    error = "..."  -- ACCOUNT_NOT_FOUND, INSUFFICIENT_PERMISSIONS
}
```

---

### `list`
List all account names. Requires session. Requires nation consent >= 1.0 or `accounts.view_others` permission.

**Request**
```lua
{
    action = "list",
    token = "..."
}
```

**Response (success)**
```lua
{
    action = "list",
    status = "success",
    data = { "name1", "name2", ... }
}
```

**Response (failure)**
```lua
{
    action = "list",
    status = "failure",
    error = "..."  -- INSUFFICIENT_PERMISSIONS
}
```

---

## Header: `wallet`
*All wallet actions are AES encrypted and require an active session.*

---

### `view`
View wallet data. Must be a member of the wallet, or have the `wallets.view_others` permission.

**Request**
```lua
{
    action = "view",
    token = "...",
    wallet = "walletName"
}
```

**Response (success)**
```lua
{
    action = "view",
    status = "success",
    data = {
        id = "...",
        name = "...",
        members = { accountName = "owner|associate", ... },
        balance = 0,
        locked = false,
        creationDate = "...",
        creationTime = "..."
    }
}
```

**Response (failure)**
```lua
{
    action = "view",
    status = "failure",
    error = "..."  -- WALLET_NOT_FOUND, INSUFFICIENT_PERMISSIONS
}
```

---

### `transfer`
Transfer funds between wallets. Must be a member of the sender wallet.

**Request**
```lua
{
    action = "transfer",
    token = "...",
    sender = "senderWalletName",
    receiver = "receiverWalletName",
    value = 0
}
```

**Response (success)**
```lua
{
    action = "transfer",
    status = "success"
}
```

**Response (failure)**
```lua
{
    action = "transfer",
    status = "failure",
    error = "..."  -- INSUFFICIENT_PERMISSIONS, INSUFFICIENT_FUNDS, TRANSACTION_INVALID_NUMBER, TRANSACTION_UNKNOWN_RECEIVER, TRANSACTION_TRANSFER_TO_SELF, WALLET_LOCKED
}
```

---

### `create`
Create a new wallet. Requires `wallets.create` permission. Subject to hourly creation limit.

**Request**
```lua
{
    action = "create",
    token = "...",
    name = "walletName"
}
```

**Response (success)**
```lua
{
    action = "create",
    status = "success"
}
```

**Response (failure)**
```lua
{
    action = "create",
    status = "failure",
    error = "..."  -- INSUFFICIENT_PERMISSIONS, WALLET_EXISTS, WALLET_LIMIT_REACHED, WALLET_INVALID_CHAR, etc.
}
```

---

### `delete`
Delete a wallet. Must be owner of the wallet.

**Request**
```lua
{
    action = "delete",
    token = "...",
    wallet = "walletName"
}
```

**Response (success)**
```lua
{
    action = "delete",
    status = "success"
}
```

**Response (failure)**
```lua
{
    action = "delete",
    status = "failure",
    error = "..."  -- WALLET_NOT_FOUND, INSUFFICIENT_PERMISSIONS
}
```

---

### `add_member`
Add a member to a wallet. Must be owner. Role must be `"owner"` or `"associate"`.

**Request**
```lua
{
    action = "add_member",
    token = "...",
    wallet = "walletName",
    member = "accountName",
    role = "owner|associate"
}
```

**Response (success)**
```lua
{
    action = "add_member",
    status = "success"
}
```

**Response (failure)**
```lua
{
    action = "add_member",
    status = "failure",
    error = "..."  -- WALLET_NOT_FOUND, INSUFFICIENT_PERMISSIONS, WALLET_MEMBER_EXISTS, WALLET_INVALID_ROLE, WALLET_ACCOUNT_NOT_FOUND, WALLET_LOCKED
}
```

---

### `remove_member`
Remove a member from a wallet. Must be owner.

**Request**
```lua
{
    action = "remove_member",
    token = "...",
    wallet = "walletName",
    member = "accountName"
}
```

**Response (success)**
```lua
{
    action = "remove_member",
    status = "success"
}
```

**Response (failure)**
```lua
{
    action = "remove_member",
    status = "failure",
    error = "..."  -- WALLET_NOT_FOUND, INSUFFICIENT_PERMISSIONS, WALLET_ACCOUNT_NOT_FOUND, WALLET_LOCKED
}
```