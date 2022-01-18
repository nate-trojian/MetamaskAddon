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

See https://chainlist.org/ for list of each chain and their ID

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


# Project Settings
|Name|Type|Description|Default|
|---|---|---|---|
|plugins/metamask/use_application_icon|Bool|Whether Metamask should use your Application's Icon in the Connect Popup|False|
