# GuardLink Client API
The GuardLink Client API offers an easy way to securely communicate with any nation that uses the GuardLink infrastructure. It's designed to be minimal and give the developer control, while abstracting the tedious parts. Install the API file somewhere on your computer and load it with `require()`.

## Quickstart
```lua
local api = require("guardlink")

api.init()
api.broadcast(5, function(response)
    api.auth("MyNation", "username", "password", function(response)
        if response.payload.status == "success" then
            print("Logged in! ClientID: " .. api.clientID)
        end
    end)
end)

parallel.waitForAll(
    function()
        api.listen(function(msg)
            print("Received: " .. msg.header)
        end)
    end,
    function()
        -- your code here
    end
)
```

## Functions

`init()` - Finds the wireless modem, opens the discovery channel, and loads or generates an RSA keypair. Must be called before anything else.

---

`broadcast(timeout, callback)` - Broadcasts on the discovery channel and collects responding servers into `api.nations`. The callback fires once per responding server, and `timeout` controls how long to listen for responses (in seconds).

Each response contains:
- `payload.name` - the nation name
- `payload.key.shared` and `payload.key.public` - the server's public key
- `payload.certificate` - present if the server has a trust certificate

Discovered servers are stored in `api.nations` keyed by name, each with `shared`, `public`, and `trusted` fields. If a server is not trusted it is up to the user/developer if they want to connect to the server anyways.

---

`auth(nation, name, password, callback)` - Authenticates with a nation. The nation must exist in `api.nations`. On success, the callback receives a response with `payload.status = "success"` and session state is stored automatically. On failure, `payload.status = "failure"` and `payload.error` contains the reason.

---

`createAccount(nation, name, password, callback, inviteCode)` - Registers a new account on the given nation. If the server is invite-only, `inviteCode` is required. The callback receives a response with `payload.status` of either `"success"` or `"failure"`.

---

`send(header, payload, callback, limit, timeout)` - Encrypts and transmits a message on the active session channel. Requires a valid session from `auth()`. The callback is called when a response with the matching message ID arrives. `limit` controls how many responses the callback accepts before expiring (default 1), and `timeout` is an optional expiry in seconds. The shape of the response depends on the dispatcher.

---

`listen(onEvent)` - Blocking event loop that handles incoming messages. Internal events like heartbeats and channel rotation are handled automatically. Any message not tied to a callback is forwarded to `onEvent(content)`. Intended to be run in parallel to your own code.

---

`disconnect()` - Sends a disconnect notice to the server, closes all channels, and resets all session state. If you want to log out without wiping the API state, do it via the `network` header and the `disconnect` action. 

## State
These fields are set automatically during the lifecycle and are available for inspection.

| Field | Description |
|-------|-------------|
| `api.nations` | Table of discovered servers, keyed by name, each with `shared`, `public`, and `trusted` fields |
| `api.sessionToken` | Token issued on login |
| `api.channel` | Active session channel |
| `api.clientID` | Unique client ID assigned by the server |

## Dispatchers
Dispatchers are server-side handlers that process incoming requests and send back a response. Each dispatcher is identified by a `header` and a `payload.action`. You interact with them through `api.send()`.

All responses follow this shape:
- `header` - What type of message you are sending
- `payload.action` - Action of the request (for example "ping" for pinging the server)
- `payload.status` - either `"success"` or `"failure"`
- `payload.error` - present on failure, contains an error message
- `payload.data` - if the request was successful, this is where the data lives

**Example**
```lua
api.send("account", { action = "info", name = "Alice" }, function(response)
    if response.payload.status == "success" then
        print(response.payload.data.username)
    else
        print(response.payload.error)
    end
end)
```


### network

| Action | Request fields | Response |
|--------|---------------|---------|
| `discovery` | *(handled by `api.broadcast()`)* | `payload.key`, `payload.name`, and optionally `payload.certificate` if the server is trusted |
| `heartbeat` | *(handled internally by `api.listen()`)* | No response |
| `disconnect` | - | No response |
| `ping` | - | `payload.timestamp` - server time at the moment of response. Works before authentication |

### nation

| Action | Request fields | Response |
|--------|---------------|---------|
| `info` | - | `payload.data` - nation name, tag, currency name, and ethic. Works before authentication |
| `stats` | - | `payload.data` - nation statistics. Requires authentication |

### admin

The admin header is a general-purpose dispatcher for privileged accounts. It does not have a fixed set of actions, instead `payload.action` specifies a service and `payload.command` specifies the command to run. The required permission is defined as `service.command` and checked automatically.

| Request field | Type | Description |
|---------------|------|-------------|
| `action` | string | The target service (e.g. `"accounts"`) |
| `command` | string | The command to execute on that service |
| `args` | table | Arguments passed to the command. Shape depends on the service and command |

On success, `payload.data` contains the result of the command. The available services and commands depend on the server configuration and what permissions your account has been granted.

### account

| Action | Request fields | Response |
|--------|---------------|---------|
| `login` | *(handled by `api.auth()`)* | `payload.token`, `payload.channel`, `payload.clientID` on success |
| `register` | *(handled by `api.createAccount()`)* | Only returns status. Fails if registration limit is reached or invite code is invalid |
| `info` | `name: string` | `payload.data` - sanitized account data. Requires high nation consent or `accounts.view_others` permission to view other accounts |
| `list` | - | `payload.data` - list of all accounts. Same permission rules as `info` |
| `change_password` | `old_password: string`, `new_password: string` | Only returns status |
| `audit` | `name: string` | `payload.data` - audit log entries. Nation Ethic or `accounts.view_others` permission determines whether you can view logs from other accounts |

### wallet

| Action | Request fields | Response |
|--------|---------------|---------|
| `info` | `wallet: string` | `payload.data` - full wallet data. Must be a member or have `wallets.view_others` permission |
| `transfer` | `sender: string`, `receiver: string`, `value: number` | Only returns status. Must be a member of the sender wallet |
| `create` | `wallet: string` | Only returns status. Requires `wallets.create` permission. Creator is automatically added as owner with the nation's starting balance if configured |
| `delete` | `wallet: string` | Only returns status. Requires owner role |
| `add_member` | `wallet: string`, `member: string`, `role: string` | Only returns status. Requires owner role |
| `remove_member` | `wallet: string`, `member: string` | Only returns status. Requires owner role |
| `audit` | `wallet: string` | `payload.data` - audit log entries. Must be a member, have `wallets.view_others` permission, or public logs enabled |
| `get_transfer_info` | `entity_type: string` *(optional)* | `payload.data.tax` and `payload.data.cap` - current transfer tax and cap for the given entity type. Defaults to `"account"` |

### law

**Public**

| Action | Request fields | Response |
|--------|---------------|---------|
| `list` | `type: string` | `payload.data` - list of laws, filtered by category |
| `get` | `id: string` | `payload.data` - a single law by ID |
| `list_categories` | - | `payload.data` - list of configured law categories |
| `get_by_category` | `id: string` | `payload.data` - all laws in the given category |
| `list_violations` | `entity: table` | `payload.data` - violations for the given entity. Only accessible for your own account or if public logs are enabled |

**Restricted**

| Action | Request fields | Permission | Response |
|--------|---------------|------------|---------|
| `new_law` | `law: table` | `law.create` | `payload.data.id` - the ID of the created law |
| `delete_law` | `id: string` | `law.delete` | Only returns status |
| `set_active` | `id: string`, `state: boolean` | `law.toggle` | Only returns status |
| `new_category` | `name: string` | `law.manage_categories` | Only returns status |
| `delete_category` | `id: string` | `law.manage_categories` | Only returns status |
| `add_violation` | `entity: table`, `law_id: string`, `notes: string` | `law.manage_violations` | Only returns status |
| `remove_violation` | `entity: table`, `violation_id: string` | `law.manage_violations` | Only returns status |