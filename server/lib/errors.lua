local errors = {
    -- ACCOUNT RELATED -------------------------------------------------------------
    ACCOUNT_EXISTS = {
        client = "ACCOUNT_EXISTS",
        log = "Failed to create account: Already exists!"
    },
    ACCOUNT_NAME_EMPTY = {
        client = "ACCOUNT_NAME_EMPTY",
        log = "Failed to create account: Name cannot be empty!"
    },
    ACCOUNT_PASSWORD_EMPTY = {
        client = "ACCOUNT_PASSWORD_EMPTY",
        log = "Failed to create account: Password cannot be empty!"
    },
    ACCOUNT_INVALID_CHAR = {
        client = "ACCOUNT_INVALID_CHAR",
        log = "Failed to create account: Name contains invalid characters!" 
    },
    ACCOUNT_NOT_FOUND = {
        client = "ACCOUNT_NOT_FOUND",
        log = "Account could not be found!"
    },
    ACCOUNT_NAME_TOO_LONG = {
        client = "ACCOUNT_NAME_TOO_LONG",
        log = "Failed to create account: name too long!" 
    },
    ACCOUNT_NAME_TOO_SHORT = {
        client = "ACCOUNT_NAME_TOO_SHORT",
        log = "Failed to create account: name too short!" 
    },
    INVALID_TIME_FORMAT = {
        client = "INTERNAL_SERVER_ERROR",
        log = "Invalid time format!"
    },
    INVALID_CREDENTIALS = {
        client ="INVALID_CREDENTIALS",
        log = "Invalid credentials"
    },
    UNKNOWN_INVITE_CODE = {
        client = "UNKNOWN_INVITE_CODE",
        log = "Tried to access unknown invite code"
    },
    EXPIRED_INVITE_CODE = {
        client = "EXPIRED_INVITE_CODE",
        log = "Tried to access expired invite code"
    },
    REGISTRATION_LIMIT_REACHED = {
        client = "INTERNAL_SERVER_ERROR",
        log = "Registration limit reached for this hour"
    },
    MISSING_INVITE_CODE = {
        client = "MISSING_INVITE_CODE",
        log = "Missing invite code"
    },
    -- ACCOUNT RELATED -------------------------------------------------------------

    -- WALLET RELATED --------------------------------------------------------------
    WALLET_EXISTS = {
        client = "WALLET_EXISTS",
        log = "Failed to create wallet: Already exists!"
    },
    WALLET_NAME_EMPTY = {
        client = "WALLET_NAME_EMPTY",
        log = "Failed to create wallet: Name cannot be empty!"
    },
    WALLET_INVALID_CHAR = {
        client = "WALLET_INVALID_CHAR",
        log = "Failed to create wallet: Name contains invalid characters!"
    },
    WALLET_MEMBER_EXISTS = {
        client = "WALLET_MEMBER_EXISTS",
        log = "Failed to add member to wallet: Already a member!"
    },
    WALLET_MEMBER_NOT_FOUND = {
        client = "WALLET_MEMBER_NOT_FOUND",
        log = "Member not found in wallet!"
    },
    WALLET_INVALID_ROLE = {
        client = "WALLET_INVALID_ROLE",
        log = "Failed to add member to wallet: Invalid role!"
    },
    WALLET_NOT_FOUND = {
        client = "WALLET_NOT_FOUND",
        log = "Unknown error: Wallet could not be found!"
    },
    WALLET_ACCOUNT_NOT_FOUND = {
        client = "WALLET_ACCOUNT_NOT_FOUND",
        log = "Failed to add account to wallet: Account could not be found!"
    },
    WALLET_LOCKED = {
        client = "WALLET_LOCKED",
        log = "Failed to do operation: Wallet is locked!" 
    },
    WALLET_NAME_TOO_LONG = {
        client = "WALLET_NAME_TOO_LONG",
        log = "Failed to create wallet: name too long!" 
    },
    WALLET_NAME_TOO_SHORT = {
        client = "WALLET_NAME_TOO_SHORT",
        log = "Failed to create wallet: name too short!" 
    },
    BALANCE_INVALID_OPERATION = {
        client = "BALANCE_INVALID_OPERATION",
        log = "Failed to modify balance: Invalid operation!" 
    },
    TRANSACTION_INVALID_NUMBER = {
        client = "TRANSACTION_INVALID_NUMBER",
        log = "Failed to transfer balance: Invalid number!"
    },
    TRANSACTION_UNKNOWN_SENDER = {
        client = "TRANSACTION_UNKNOWN_SENDER",
        log = "Failed to transfer balance: Unknown sender!"
    },
    TRANSACTION_UNKNOWN_RECEIVER = {
        client = "TRANSACTION_UNKNOWN_RECEIVER",
        log = "Failed to transfer balance: Unknown receiver!"
    },
    TRANSACTION_TRANSFER_TO_SELF = {
        client = "TRANSACTION_TRANSFER_TO_SELF",
        log = "Failed to transfer balance: Cannot transfer to same wallet!"        
    },
    INSUFFICIENT_FUNDS = {
        client = "INSUFFICIENT_FUNDS",
        log = "Failed to transfer balance: Insufficient funds!"
    },
    TRANSFER_LIMIT_EXCEEDED = {
        client = "TRANSFER_LIMIT_EXCEEDED",
        log = "Failed to transfer balance: Amount exceeds transfer limit!"
    },
    WALLET_LIMIT_REACHED = {
        client = "WALLET_LIMIT_REACHED",
        log = "Failed to do action: Wallet limit reached!"
    },
    -- WALLET RELATED --------------------------------------------------------------

    -- NETWORK RELATED -------------------------------------------------------------
    DUPLICATE_CLIENT = {
        client = "DUPLICATE_CLIENT",
        log = "Failed to register client: already connected!"             
    },
    UNKNOWN_CLIENT = {
        client = "UNKNOWN_CLIENT",
        log = "Tried to modify unknown client!"             
    },
    SERVER_FULL = {
        client = "SERVER_FULL",
        log = "Failed to register client: max capacity reached!"             
    },
    CHANNEL_ALREADY_OPEN = {
        client = "CHANNEL_ALREADY_OPEN",
        log = "Failed to open port: port already open!"      
    },
    CHANNEL_ALREADY_CLOSED = {
        client = "CHANNEL_ALREADY_CLOSED",
        log = "Failed to open port: port already closed!"    
    },
    CHANNEL_CAPACITY_REACHED = {
        client = "CHANNEL_CAPACITY_REACHED",
        log = "Failed to open port: Channel capacity reached!"            
    },
    INVALID_MESSAGE_FORMAT = {
        client = "INVALID_MESSAGE_FORMAT",
        log = "Failed to create message: Invalid format!"           
    },
    QUEUE_FULL = {
        client = "QUEUE_FULL",
        log = "Failed to add request: Queue full!"
    },
    MALFORMED_MESSAGE = {
        client = "MALFORMED_MESSAGE",
        log = "Failed to process request: Malformed message!"        
    },
    UNKNOWN_DISPATCHER = {
        client = "MALFORMED_MESSAGE",
        log = "Failed to process message: Unknown action!"
    },
    MISSING_PAYLOAD = {
        client = "MALFORMED_MESSAGE",
        log = "Failed to process message: Missing payload!"
    },
    TOKEN_MISMATCH = {
        client = "MALFORMED_MESSAGE",
        log = "Failed to process message: Token mismatch!"
    },
    NO_CLIENTS = {
        client = "INTERNAL_SERVER_ERROR",
        log = "No clients found!"
    },
    -- NETWORK RELATED -------------------------------------------------------------

    -- UI RELATED ------------------------------------------------------------------
    UNKNOWN_UI = {
        client = "INTERNAL_ERROR",
        log = "Failed to load UI: unknown path!"
    },
    -- UI RELATED ------------------------------------------------------------------

    ROLES_EXCEED_CAPACITY = {
        client = "ROLES_EXCEED_CAPACITY",
        log = "Cannot add role: Full capacity"
    },
    ROLE_EXISTS = {
        client = "ROLE_EXISTS",
        log = "Cannot add role: Role already exists"
    },
    ROLE_NOT_FOUND = {
        client = "ROLE_NOT_FOUND",
        log = "Role not found"
    },
    PERMISSION_EXISTS = {
        client = "PERMISSION_EXISTS",
        log = "Permission already exists"
    },
    PERMISSION_NOT_FOUND = {
        client = "PERMISSION_NOT_FOUND",
        log = "Permission not found"        
    },
    ROLE_FULL = {
        client = "ROLE_FULL",
        log = "Failed to assign role: No seats left"
    },
    ACCOUNT_HAS_NO_ROLE = {
        client = "ACCOUNT_HAS_NO_ROLE",
        log = "Account has no role"
    },
    ROLE_SEATS_BELOW_OCCUPIED = {
        client = "ROLE_SEATS_BELOW_OCCUPIED",
        log = "New seat amount cant be smaller than the current member count"
    },
    INSUFFICIENT_PERMISSIONS = {
        client = "INSUFFICIENT_PERMISSIONS",
        log = "Insufficient permissions"        
    },
    INVALID_INPUT = {
        client = "INVALID_INPUT",
        log = "Entered invalid values"
    },
    UNKNOWN_LAW = {
        client = "UNKNOWN_LAW",
        log = "Unknown Law"
    },
    INVALID_ENTITY_TYPE = {
        client = "INVALID_ENTITY_TYPE",
        log = "Invalid entity type"
    },
    INVALID_ENTITY_NAME = {
        client = "INVALID_ENTITY_NAME",
        log = "Invalid entity name"
    },
    INVALID_AMOUNT = {
        client = "INVALID_AMOUNT",
        log = "Amount must be greater than zero"
    },
    DEBT_NOT_FOUND = {
        client = "DEBT_NOT_FOUND",
        log = "Debt record not found"
    },
    CATEGORY_EXISTS = {
        client = "INTERNAL_ERROR",
        log = "Category already exists"
    },
    UNKNOWN_CATEGORY = {
        client = "INTERNAL_ERROR",
        log = "Category does not exist"
    },
    UNRESOLVED_DEPENDENCIES = {
        client = "INTERNAL_ERROR",
        log = "Failed to do action: unresolved dependencies"
    },
    LAW_NOT_FOUND = {
        client = "LAW_NOT_FOUND",
        log = "Law not found"
    },
    LAW_EXISTS = {
        client = "LAW_EXISTS",
        log = "A law with that name already exists"
    },
    LAW_LIMIT_REACHED = {
        client = "LAW_LIMIT_REACHED",
        log = "Law limit reached for this nation"
    },
    INVALID_LAW_TYPE = {
        client = "INVALID_LAW_TYPE",
        log = "Invalid law type"
    },
    INVALID_TARGET = {
        client = "INVALID_TARGET",
        log = "Invalid or missing target"
    },
    INVALID_EFFECT = {
        client = "INVALID_EFFECT",
        log = "Invalid or missing effect"
    },
    INVALID_FORMAT = {
        client = "INVALID_FORMAT",
        log = "Invalid format"
    },
    DEGRADED_DISK = {
        client = "INTERNAL_ERROR",
        log = "Partition is degraded: missing disk"
    },
}

return errors