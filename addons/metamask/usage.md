# Metamask
## Signals
### New Account Selected
```
# new_accounts - Array of accounts user has changed to AND Application has permissions to see
signal accounts_changed(new_accounts: Array[String])
```
Signal when user changes their active accounts. Currently only one account is active at a time but can potentially be more in the future

### New Chain Selected
```
# new_chain_id - String corresponding to the new Chain's ID
signal chain_changed(new_chain_id: String)
```
Signal when user changes their connected chain. See https://chainlist.org/ for list of each chain and their ID

### Request Accounts Result
```
# success - Array of address strings. Null if call failed
# error - Dict containing "code" and "message" keys. Null if call succeeded
signal request_accounts_finished(success, error)
```
Signal to get result of `request_accounts()` method call

## Functions
### Is Metamask Installed
```
func has_metamask() -> bool
```
Checks if client has Metamask installed
NOTE - This is not 100% accurate.  Because it is checking a JS property, this can be faked by another wallet provider.
See [the Metamask docs](https://docs.metamask.io/guide/ethereum-provider.html#ethereum-isconnected) for details

### Is the Network Connected
```
func is_network_connected() -> bool
```
Checks if Metamask can talk to the current chain.  Fails when the user is having network connectivity issues or the chain is experiencing difficulties

### Request User Account(s)
```
func request_accounts()
```
Requests permission to view user's accounts. Fires request_accounts_finished when complete.
Currently only returns the active account in Metamask, but passes back an Array for future proofing

# Project Settings
|Name|Type|Description|Default|
|---|---|---|---|
|plugins/metamask/use_application_icon|Bool|Whether Metamask should use your Application's Icon in the Connect Popup|False|
