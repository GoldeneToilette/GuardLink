local errors = {
    -- ACCOUNT RELATED -------------------------------------------------------------
    ACCOUNT_EXISTS = {
        client = "ACCOUNT_EXISTS",
        log = "[AccountManager] Failed to create account: Already exists! "
    },
    ACCOUNT_NAME_EMPTY = {
        client = "ACCOUNT_NAME_EMPTY",
        log = "[accountManager] Failed to create account: Name cannot be empty! "
    },
    ACCOUNT_PASSWORD_EMPTY = {
        client = "ACCOUNT_PASSWORD_EMPTY",
        log = "[accountManager] Failed to create account: Password cannot be empty! "
    },
    ACCOUNT_INVALID_CHAR = {
        client = "ACCOUNT_INVALID_CHAR",
        log = "[accountManager] Failed to create account: Name contains invalid characters! " 
    },
    ACCOUNT_NOT_FOUND = {
        client = "ACCOUNT_NOT_FOUND",
        log = "[accountManager] Account could not be found! "
    },
    ACCOUNT_NAME_TOO_LONG = {
        client = "ACCOUNT_NAME_TOO_LONG",
        log = "[accountManager] Failed to create account: name too long! " 
    },
    ACCOUNT_NAME_TOO_SHORT = {
        client = "ACCOUNT_NAME_TOO_SHORT",
        log = "[accountManager] Failed to create account: name too short! " 
    },
    -- ACCOUNT RELATED -------------------------------------------------------------

    -- WALLET RELATED --------------------------------------------------------------
    WALLET_EXISTS = {
        client = "WALLET_EXISTS",
        log = "[WalletManager] Failed to create wallet: Already exists! "
    },
    WALLET_NAME_EMPTY = {
        client = "WALLET_NAME_EMPTY",
        log = "[WalletManager] Failed to create wallet: Name cannot be empty! "
    },
    WALLET_INVALID_CHAR = {
        client = "WALLET_INVALID_CHAR",
        log = "[WalletManager] Failed to create wallet: Name contains invalid characters! "
    },
    WALLET_MEMBER_EXISTS = {
        client = "WALLET_MEMBER_EXISTS",
        log = "[WalletManager] Failed to add member to wallet: Already a member! "
    },
    WALLET_INVALID_ROLE = {
        client = "WALLET_INVALID_ROLE",
        log = "[WalletManager] Failed to add member to wallet: Invalid role! "
    },
    WALLET_NOT_FOUND = {
        client = "WALLET_NOT_FOUND",
        log = "[WalletManager] Unknown error: Wallet could not be found! "
    },
    WALLET_ACCOUNT_NOT_FOUND = {
        client = "WALLET_ACCOUNT_NOT_FOUND",
        log = "[WalletManager] Failed to add account to wallet: Account could not be found! "
    },
    WALLET_LOCKED = {
        client = "WALLET_LOCKED",
        log = "[WalletManager] Failed to do operation: Wallet is locked! " 
    },
    WALLET_NAME_TOO_LONG = {
        client = "WALLET_NAME_TOO_LONG",
        log = "[WalletManager] Failed to create wallet: name too long! " 
    },
    WALLET_NAME_TOO_SHORT = {
        client = "WALLET_NAME_TOO_SHORT",
        log = "[WalletManager] Failed to create wallet: name too short! " 
    },
    BALANCE_INVALID_OPERATION = {
        client = "BALANCE_INVALID_OPERATION",
        log = "[WalletManager] Failed to modify balance: Invalid operation! " 
    },
    TRANSACTION_INVALID_NUMBER = {
        client = "TRANSACTION_INVALID_NUMBER",
        log = "[WalletManager] Failed to transfer balance: Invalid number! "
    },
    TRANSACTION_UNKNOWN_SENDER = {
        client = "TRANSACTION_UNKNOWN_SENDER",
        log = "[WalletManager] Failed to transfer balance: Unknown sender! "
    },
    TRANSACTION_UNKNOWN_RECEIVER = {
        client = "TRANSACTION_UNKNOWN_RECEIVER",
        log = "[WalletManager] Failed to transfer balance: Unknown receiver! "
    },
    TRANSACTION_TRANSFER_TO_SELF = {
        client = "TRANSACTION_TRANSFER_TO_SELF",
        log = "[WalletManager] Failed to transfer balance: Cannot transfer to same wallet! "        
    },
    INSUFFICIENT_FUNDS = {
        client = "INSUFFICIENT_FUNDS",
        log = "[WalletManager] Failed to transfer balance: Insufficient funds! "             
    },
    -- WALLET RELATED --------------------------------------------------------------

    -- NETWORK RELATED -------------------------------------------------------------
    DUPLICATE_CLIENT = {
        client = "DUPLICATE_CLIENT",
        log = "[clientManager] Failed to register client: already connected! "             
    },
    UNKNOWN_CLIENT = {
        client = "UNKNOWN_CLIENT",
        log = "[clientManager] Tried to modify unknown client! "             
    },
    SERVER_FULL = {
        client = "SERVER_FULL",
        log = "[clientManager] Failed to register client: max capacity reached! "             
    },
    CHANNEL_ALREADY_OPEN = {
        client = "CHANNEL_ALREADY_OPEN",
        log = "[networkSession] Failed to open port: port already open! "      
    },
    CHANNEL_ALREADY_CLOSED = {
        client = "CHANNEL_ALREADY_CLOSED",
        log = "[networkSession] Failed to open port: port already closed! "    
    },
    CHANNEL_CAPACITY_REACHED = {
        client = "CHANNEL_CAPACITY_REACHED",
        log = "[networkSession] Failed to open port: Channel capacity reached! "            
    },
    INVALID_MESSAGE_FORMAT = {
        client = "INVALID_MESSAGE_FORMAT",
        log = "[networkSession] Failed to create message: Invalid format! "           
    },
    QUEUE_FULL = {
        client = "QUEUE_FULL",
        log = "[requestQueue] Failed to add request: Queue full! "
    },
    MALFORMED_MESSAGE = {
        client = "MALFORMED_MESSAGE",
        log = "[requestQueue] Failed to process request: Malformed message! "        
    },
    UNKNOWN_DISPATCHER = {
        client = "MALFORMED_MESSAGE",
        log = "[dispatcher] Failed to process message: Unknown action! "
    },
    MISSING_PAYLOAD = {
        client = "MALFORMED_MESSAGE",
        log = "[dispatcher] Failed to process message: Missing payload! "
    },
    TOKEN_MISMATCH = {
        client = "MALFORMED_MESSAGE",
        log = "[dispatcher] Failed to process message: Token mismatch! "
    },
    -- NETWORK RELATED -------------------------------------------------------------

    -- UI RELATED ------------------------------------------------------------------
    UNKNOWN_UI = {
        client = "INTERNAL_ERROR",
        log = "[uiState] Failed to load UI: unknown path! "
    }
    -- UI RELATED ------------------------------------------------------------------
}

return errors