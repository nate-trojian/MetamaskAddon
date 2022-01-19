extends Node

# Signal to get result of request_accounts call
# response: Response[Array[String]] - Result is an array of addresses that the wallet now has permission to use
# NOTE - At this moment, this will always be of size 0 or 1
signal request_accounts_finished(response)
# Signal to get result of switch_to_chain call
# response: Response[null] - Result is null if call succeeded
signal switch_chain_finished(response)
# Signal to get result of client_version call
# response: Response[String] - Result is a string of the client's version
signal client_version_finished(response)
# Signal to get result of wallet_balance call
# Response[Int] - Result is integer value of wallet balance in wei
signal wallet_balance_finished(response) 

# Signal when user changes their active accounts
# Currently only one account is active at a time but can potentially be more in the future
# New Accounts - Array of accounts user has changed to AND Application has permissions to see
signal accounts_changed(new_accounts)
# Signal when user changes their connected chain
# New Chain Id - String corresponding to the new Chain's ID
# See https://chainlist.org/ for list of each chain and their ID
signal chain_changed(new_chain_id)
# Signal when Metamask connects to the active chain
# chain_id: String - Id of chain Metamask has connected to
signal chain_connected(chain_id)
# Signal when Metamask disconnects from the active chain
# error: Dict - Contains "code" and "message" fields describing the error that occurred
signal chain_disconnected(error)
# Signal when a message is received by Metamask
# message: Dict - Contains "type" and "data" fields 
signal message_received(message)

onready var convert_util: JavaScriptConvert = $JavaScriptConvert

# Credit to GodotTutorial for the 'protected' variable trick
# https://www.youtube.com/watch?v=NkEQyYXHyEk
var _base_property = 'plugins/metamask/' setget _protectedSet, _protectedGet
var _property_defaults = {
    'use_application_icon': false,
} setget _protectedSet, _protectedGet

var _document = JavaScript.get_interface('document') setget _protectedSet, _protectedGet
var _window = JavaScript.get_interface('window') setget _protectedSet, _protectedGet
var _ethereum = JavaScript.get_interface('ethereum') setget _protectedSet, _protectedGet

# Request Callbacks
var _eth_success_callback = JavaScript.create_callback(self, "_eth_request_success") setget _protectedSet, _protectedGet
var _eth_failure_callback = JavaScript.create_callback(self, "_eth_request_failure") setget _protectedSet, _protectedGet
var _wallet_balance_success_callback = JavaScript.create_callback(self, "_wallet_balance_success") setget _protectedSet, _protectedGet

# Event Callbacks
var _accounts_callback = JavaScript.create_callback(self, "_on_accounts_changed") setget _protectedSet, _protectedGet
var _chain_callback = JavaScript.create_callback(self, "_on_chain_changed") setget _protectedSet, _protectedGet
var _connected_callback = JavaScript.create_callback(self, "_on_chain_connected") setget _protectedSet, _protectedGet
var _disconnected_callback = JavaScript.create_callback(self, "_on_chain_disconnected") setget _protectedSet, _protectedGet
var _message_callback = JavaScript.create_callback(self, "_on_message_received") setget _protectedSet, _protectedGet

var _events_to_callbacks: Dictionary = {
    'accountsChanged': _accounts_callback,
    'chainChanged': _chain_callback,
    'connect': _connected_callback,
    'disconnect': _disconnected_callback,
    'message': _message_callback
} setget _protectedSet, _protectedGet

func _protectedSet(_val):
    push_error('cannot access protected variable')

func _protectedGet():
    push_error('cannot access protected variable')

func _ready():
    _create_request_wrapper()
    _load_config()
    _create_event_listeners()

func _create_request_wrapper():
    # TODO - See if there's a good way of importing this at run time
    var script_txt = "async function requestWrapper(requestBody, signal, success, failure) { try { result = await ethereum.request(requestBody); console.log(result); success(signal, result); } catch (e) { console.error(e); err_dict = { 'code': e.code, 'message': e.message }; failure(signal, err_dict); }}"
    # Create the block
    var script_block = _document.createElement('script')
    script_block.id = 'requestWrapper'
    var text_block = _document.createTextNode(script_txt)
    script_block.appendChild(text_block)
    _document.head.appendChild(script_block)

func _load_config():
    # Setup defaults for values if they are not already there
    for property in _property_defaults:
        if not ProjectSettings.has_setting(_base_property + property):
            ProjectSettings.set_setting(_base_property + property, _property_defaults[property])
    # Application Icon
    if ProjectSettings.get_setting(_base_property + 'use_application_icon'):
        _create_application_icon()

# Make your Application's icon show as the icon in the MetaMask popup
func _create_application_icon():
    var gd_icon = _document.getElementById('-gd-engine-icon')
    var metamaskIcon = _document.createElement('link')
    metamaskIcon.id = 'metamaskIcon'
    metamaskIcon.rel = 'shortcut icon'
    metamaskIcon.href = gd_icon.href
    _document.head.appendChild(metamaskIcon)

func _create_event_listeners():
    for event in _events_to_callbacks:
        var callback = _events_to_callbacks[event]
        _ethereum.on(event, callback)

func _exit_tree():
    for event in _events_to_callbacks:
        var callback = _events_to_callbacks[event]
        _ethereum.removeListener(event, callback)

func _on_accounts_changed(new_accounts):
    var val = convert_util.to_GDScript(new_accounts[0])
    emit_signal("accounts_changed", val)

func _on_chain_changed(new_chain):
    var val = convert_util.to_GDScript(new_chain[0])
    emit_signal("chain_changed", val)

func _on_chain_connected(chain):
    var val = convert_util.to_GDScript(chain[0])
    emit_signal("chain_connected", val)

func _on_chain_disconnected(error):
    var val = convert_util.to_GDScript(error[0])
    emit_signal("chain_disconnected", val)

func _on_message_received(message):
    var val = convert_util.to_GDScript(message[0])
    emit_signal("message_received", val)

# Helper method for building the request body for RPC calls
func _build_request_body(method: String, params = null) -> JavaScriptObject:
    var request_body = JavaScript.create_object('Object')
    request_body['method'] = method
    match typeof(params):
        TYPE_NIL:
            # If params is null, just continue
            pass
        TYPE_ARRAY:
            request_body['params'] = convert_util.arr_to_js(params)
        TYPE_DICTIONARY:
            var params_body = convert_util.dict_to_js(params)
            request_body['params'] = JavaScript.create_object('Array', params_body)
        _:
            # If we give just a single primitive, give it in an array
            # Looking at you eth_getBalance
            request_body['params'] = JavaScript.create_object('Array', 1)
            request_body['params'][0] = params
    return request_body

# Request wrapper so we can have default arguments
func _request_wrapper(request_body: JavaScriptObject,
                        signal_name: String,
                        success: JavaScriptObject = _eth_success_callback,
                        failure: JavaScriptObject = _eth_failure_callback):
    # Since we are doing dynamic signal emitting, we better make sure that it actually exists
    if not self.has_signal(signal_name):
        push_error("Unknown signal name: " + signal_name)
        return
    _window.requestWrapper(request_body, signal_name, success, failure)

func _eth_request_success(args):
    var signal_name = args[0]
    var result = convert_util.to_GDScript(args[1])
    emit_signal(signal_name, {'result': result, 'error': null})

func _eth_request_failure(args):
    var signal_name = args[0]
    var error = convert_util.to_GDScript(args[1])
    emit_signal(signal_name, {'result': null, 'error': error})

# Checks if client has Metamask installed
# NOTE - This is not 100% accurate.  Because it is checking a JS property, this can be faked by another wallet provider.
# See https://docs.metamask.io/guide/ethereum-provider.html#ethereum-isconnected for details
func has_metamask() -> bool:
    return _ethereum != null && _ethereum.isMetaMask

# Checks if Metamask can talk to the current chain
func is_network_connected() -> bool:
    return _ethereum.isConnected()

# Gets the current connected chain id
func current_chain() -> String:
    return _ethereum.chainId

# Gets the active account address or null if no account is connected
func selected_account() -> String:
    return _ethereum.selectedAddress

# Requests permission to view user's accounts. Fires request_accounts_finished when complete
# Currently only returns the active account in Metamask, but passes back an Array for future proofing
func request_accounts():
    var request_body = _build_request_body('eth_requestAccounts')
    _request_wrapper(request_body, 'request_accounts_finished')

# Sends notification to user to switch to the chain with the provided ID
func switch_to_chain(chain_id: String):
    var request_body = _build_request_body('wallet_switchEthereumChain', {'chainId': chain_id})
    _request_wrapper(request_body, 'switch_chain_finished')

# Request the version of the client we are using
func client_version():
    var request_body = _build_request_body('web3_clientVersion')
    _request_wrapper(request_body, 'client_version_finished')

# Get the balance of wallet at address in wei
func wallet_balance(address: String):
    var request_body = _build_request_body('eth_getBalance', address)
    _request_wrapper(request_body, 'wallet_balance_finished', _wallet_balance_success_callback)

# Custom success callback for wallet_balance
# Returns big-endian byte array of ethereum value in Wei
func _wallet_balance_success(args):
    # Get the hex string result
    var result: String = convert_util.to_GDScript(args[1])
    # Trim the 0x at the start
    result = result.right(2)
    # TODO - Make sure the result can even be stored in a 64bit signed int...
    # How many hex digits we are trying to handle at a time
    # hex_to_int returns a 32bit signed int, so most we can do is 28bits aka 7 chars
    var step = 7
    # Do the first step
    var num: int = str("0x" + result.substr(0, step)).hex_to_int()
    var ind = step
    # Until we surpass the string
    while ind <= len(result):
        # Get up to step characters from the string
        # Can be less characters if there aren't enough in the string
        var sub = result.substr(ind, step)
        # convert to 32bit signed int
        var hexed = ("0x"+sub).hex_to_int()
        # Shift num as many steps as we have
        num = num << (4*len(sub))
        # Add hexed to num
        num = num | hexed
        # Increment index
        ind += step
    emit_signal('wallet_balance_finished', {'result': num, 'error': null})
