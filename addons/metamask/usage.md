# Metamask
Quick links
- [Functions](#functions)
- [Signals](#signals)
- [Project Settings](#project-settings)


## Functions
### Is Metamask Installed
Checks if client has Metamask installed

NOTE - This is not 100% accurate.  Because it is checking a JS property, this can be faked by another wallet provider.

See [the Metamask docs](https://docs.metamask.io/guide/ethereum-provider.html#ethereum-isconnected) for details
```
func has_metamask() -> bool
```


### Is Network Connected
Checks if Metamask can talk to the current chain.  Returns false when the user is having network connectivity issues or the chain is experiencing difficulties
```
func is_network_connected() -> bool
```


### Current Chain
Gets the current connected chain id 
```
func current_chain() -> String
```


### Selected Account
Gets the active account address or null if no account has connected to the Application
```
func selected_account() -> String || null
```


### Request Accounts
Requests permission to view user's accounts. Fires request_accounts_finished when complete.

Currently only returns the active account in Metamask, but passes back an Array for future proofing

Result is returned by [request_accounts_finished](#request-accounts-finished) signal
```
func request_accounts()
```


### Switch to Chain
Sends notification to user to switch to the chain with the provided ID.

See https://chainlist.org/ for list of chains and their details

Result is returned by [switch_to_chain_finished](#switch-to-chain-finished) signal
```
# chain_id: String - ID of chain to connect to
func switch_to_chain(chain_id: String)
```


### Client Version
Gets the version of Metamask currently running.

Result is returned by [client_version_finished](#client-version-finished) signal
```
func client_version()
```


### Wallet Balance
Get the balance of wallet at address in wei

Result is returned by [wallet_balance_finished](#wallet-balance-finished) signal
```
# address: String - Address of wallet to retrieve ETH balance from
func wallet_balance(address: String)
```


### Token Balance
Get the balance of an ERC20 token for an address

Result is returned by [wallet_balance_finished](#wallet-balance-finished) signal
```
# token_address: String - Address of the Smart Contract for the ERC20 token
# address: String - Address to retrieve balance against
func token_balance(token_address: String, address: String)
```


### Add Ethereum Chain
Add a custom ethereum-based chain to your wallet. Examples of ethereum-based chains are [Polygon](https://polygon.technology/) and [Binance](https://www.binance.org/en)

See https://chainlist.org/ for list of chains and their details

Result is returned by [add_eth_chain_finished](#add-ethereum-chain-finished) signal
```
# chain_id: String - ID of chain to connect to
# chain_name: String - Name to show for the chain
# rpc_url: String - URL to send RPC requests to
# currency_symbol: Optional[String] - 2-6 character symbol to refer to the token used by the chain
# block_explorer_url: Optional[String] - URL of website to browse block information for the chain
func add_eth_chain(chain_id: String, chain_name: String, rpc_url: String, currency_symbol = null, block_explorer_url = null)
```


### Add Custom Token
Requests Metamask to track a specified ERC20 token in the connected account

Result is returned by [add_custom_token_finished](#add-custom-token-finished) signal
```
# token_address: String - Address of the Smart Contract for the ERC20 token
# token_symbol: String - 2-6 character symbol to refer to the token
# image_url: String - URL for image to use for the token
func add_custom_token(token_address: String, token_symbol: String, image_url: String)
```

### Current Gas Price
Get the current gas price in Wei

Result is returned by [current_gas_price_finished](#current-gas-price-finished) signal
```
func current_gas_price()
```


### Send Token
Send some amount of an ERC20 token from one account to another.

NOTE - Most ERC20 tokens will require the from_address to be the sender of the request.
In most use cases you will use `from_address = Metamask.selected_account()`

Result is returned by [send_token_finished](#send-token-finished) signal
```
# from_address: String - Wallet where the tokens will be sent from
# recipient_address: String - Wallet that will receive the tokens
# token_address: String - Address of the Smart Contract for the ERC20 token
# amount: float - Amount of the token to send.  Unit is "eth" (1e18)
# gas_limit: Optional[int] - Limit on Gas to spend on the transaction
# gas_price: Optional[float] - Price to pay per Gas unit.  Unit is "gwei" (1e9)
func send_token(from_address: String, recipient_address: String, token_address: String, amount: float, gas_limit = null, gas_price = null)
```


### Send Ethereum
Send some amount of ETH from one account to another

Result is returned by [send_eth_finished](#send-ethereum-finished) signal
```
# from_address: String - Wallet where the ETH will be sent from
# recipient_address: String - Wallet that will receive the ETH
# amount: float - Amount of the token to sell.  Unit is "eth" (1e18)
# gas_limit: Optional[int] - Limit on Gas to spend on the transaction.  Defaults to 21000, which is the constant gas needed to transfer eth between accounts
# gas_price: Optional[float] - Price to pay per Gas unit.  Unit is "gwei" (1e9)
func send_eth(from_address: String, recipient_address: String, amount: float, gas_limit: int = 21000, gas_price = null)
```


## Signals

All `<function>_finished` signals share the same Response data structure
```
Response[T] = Dictionary
{
  'result': T || null, # If the call succeeded, the data returned will be passed back here. If the call failed, it will be null
  'error': {
    'code': Int, # Code relating to the error 
    'message': String # Human readable string relating to the error
  } || null # If the call failed, error will be a Dictionary containing info about the error.  If the call succeeded, it will be null
}
```

### Request Accounts Finished
Signal to get result of [request_accounts](#request-user-accounts) call
```
# response: Response[Array[String]] - Result is an array of addresses that the wallet now has permission to use
# NOTE - At this moment, this will always be of size 0 or 1
signal request_accounts_finished(response)
```


### Switch to Chain Finished
Signal to get result of [switch_to_chain](#switch-to-chain) call
```
# response: Response[null] - Result is null if call succeeded
signal switch_chain_finished(response)
```


### Client Version Finished
Signal to get result of [client_version](#client-version) call
```
# response: Response[String] - Result is a string of the client's version
signal client_version_finished(response)
```


### Wallet Balance Finished
Signal to get result of [wallet_balance](#wallet-balance) call
```
# response: Response[Int] - Result is the integer value of wallet balance in wei
signal wallet_balance_finished(response) 
```


### Token Balance Finished
Signal to get result of [token_balance](#token-balance) call
```
# response: Response[Int] - Result is the integer value of the token associated to the address
signal token_balance_finished(response)
```


### Add Ethereum Chain Finished
Signal to get result of [add_eth_chain](#add-ethereum-chain) call
```
# response: Response[null] - Result is null if call succeeded
signal add_eth_chain(response)
```


### Add Custom Token Finished
Signal to get result of [add_custom_token](#add-custom-token) call
```
# response: Response[Int] - Result is null if call succeeded
signal add_custom_token_finished(response)
```


### Current Gas Price Finished
Signal to get result of [current_gas_price](#current-gas-price) call
```
# response: Response[int] - Result is the integer value of current gas price in wei
signal current_gas_price_finished(response)
```


### Send Token Finished
Signal to get result of [send_token](#send-token) call
```
# response: Response[String] - Result is a hex encoded transaction hash
signal send_token_finished(response)
```


### Send Ethereum Finished
Signal to get result of [send_eth](#send-ethereum) call
```
# response: Response[String] - Result is a hex encoded transaction hash
signal send_eth_finished(response)
```


### New Account Selected
Signal when user changes their active accounts.

Currently only one account is active at a time but can potentially be more in the future
```
# new_accounts: Array[String] - Array of accounts user has changed to AND Application has permissions to see
signal accounts_changed(new_accounts)
```


### New Chain Selected
Signal when user changes their connected chain.

See https://chainlist.org/ for list of chains and their details
```
# new_chain_id: String - String corresponding to the new Chain's ID
signal chain_changed(new_chain_id)
```


### Chain Connected
Signal when Metamask provider has connected to the active chain
```
# chain_id: String - Id of chain Metamask has connected to
signal chain_connected(chain_id)
```


### Chain Disconnected
Signal when Metamask disconnects from the active chain
```
# error: Dict[String, Any] - Contains "code" and "message" fields describing the error that occurred
signal chain_disconnected(error)
```


# Project Settings
|Name|Type|Description|Default|
|---|---|---|---|
|plugins/metamask/use_application_icon|Bool|Whether Metamask should use your Application's Icon in the Connect Popup|False|
