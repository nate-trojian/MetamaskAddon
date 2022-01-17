# Metamask
Quick links
- [Signals](#signals)
- [Functions](#functions)
- [Project Settings](#project-settings)


## Signals
### New Account Selected
Signal when user changes their active accounts.

Currently only one account is active at a time but can potentially be more in the future
```
# new_accounts: Array[String] - Array of accounts user has changed to AND Application has permissions to see
signal accounts_changed(new_accounts)
```


### New Chain Selected
Signal when user changes their connected chain.

See https://chainlist.org/ for list of each chain and their ID
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


### Request Accounts Result
Signal to get result of [request_accounts](#request-user-accounts) call
```
# success: Optional[Array[String]] - Array of address strings. Null if call failed
# error: Optional[Dict[String, Any]] - Dict containing "code" and "message" keys. Null if call succeeded
signal request_accounts_finished(success, error)
```


### Switch Chain Result
Signal to get result of [switch_to_chain](#switch-to-chain) call
```
# error: Optional[Dict[String, Any]] - Dict containing "code" and "message" keys. Null if call succeeded
signal switch_chain_finished(error)
```


## Functions
### Is Metamask Installed
Checks if client has Metamask installed

NOTE - This is not 100% accurate.  Because it is checking a JS property, this can be faked by another wallet provider.

See [the Metamask docs](https://docs.metamask.io/guide/ethereum-provider.html#ethereum-isconnected) for details
```
func has_metamask() -> bool
```


### Is the Network Connected
Checks if Metamask can talk to the current chain.  Returns false when the user is having network connectivity issues or the chain is experiencing difficulties
```
func is_network_connected() -> bool
```


### Request User Account(s)
Requests permission to view user's accounts. Fires request_accounts_finished when complete.

Currently only returns the active account in Metamask, but passes back an Array for future proofing
```
func request_accounts()
```


### Switch to Chain
Sends notification to user to switch to the chain with the provided ID.

See https://chainlist.org/ for list of each chain and their ID
```
# chain_id: String - ID of chain to connect to
func switch_to_chain(chain_id: String)
```


# Project Settings
|Name|Type|Description|Default|
|---|---|---|---|
|plugins/metamask/use_application_icon|Bool|Whether Metamask should use your Application's Icon in the Connect Popup|False|
