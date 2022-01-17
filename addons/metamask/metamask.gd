extends Node

# Signal from request_accounts
# Success - Array of address strings. Null if call failed
# Error - Dict containing "code" and "message" keys. Null if call succeeded
signal request_accounts_finished(success, error)
# Signal when user changes their active accounts
# Currently only one account is active at a time but can potentially be more in the future
# New Accounts - Array of accounts user has changed to AND Application has permissions to see
signal accounts_changed(new_accounts)
# Signal when user changes their connected chain
# New Chain Id - String corresponding to the new Chain's ID
# See https://chainlist.org/ for list of each chain and their ID
signal chain_changed(new_chain_id)

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

var _accounts_listener: JavaScriptObject = null setget _protectedSet, _protectedGet
var _chain_listener: JavaScriptObject = null setget _protectedSet, _protectedGet

var _request_success = JavaScript.create_callback(self, "_request_success_callback") setget _protectedSet, _protectedGet
var _request_failed = JavaScript.create_callback(self, "_request_failed_callback") setget _protectedSet, _protectedGet
var _accounts_callback = JavaScript.create_callback(self, "_on_accounts_changed") setget _protectedSet, _protectedGet
var _chain_callback = JavaScript.create_callback(self, "_on_chain_changed") setget _protectedSet, _protectedGet

func _protectedSet(_val):
    push_error('cannot access protected variable')

func _protectedGet():
    push_error('cannot access protected variable')

func _ready():
    _init_placeholder_vars()
    _create_callback_handler()
    _load_config()
    _create_event_listeners()

func _create_callback_handler():
    var script_txt = 'function callback_handler(f) { return (...args) => { window.last_returned_value = args; f(args); } }'
    var script_block = _document.createElement('script')
    script_block.id = 'callbackHelper'
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

func _init_placeholder_vars():
    # Create last_returned_value holder
    var last_returned_value = JavaScript.create_object("Array")
    _window.last_returned_value = last_returned_value

func _exit_tree():
    if _accounts_listener != null:
        _ethereum.removeListener('accountsChanged', _accounts_callback)
    if _chain_listener != null:
        _ethereum.removeListener('chainChanged', _chain_callback)

func _create_event_listeners():
    _accounts_listener = _ethereum.on('accountsChanged', _accounts_callback)
    _chain_listener = _ethereum.on('chainChanged', _chain_callback)

func _on_accounts_changed(new_accounts):
    var val = convert_util.to_GDScript(new_accounts[0])
    emit_signal("accounts_changed", val)

func _on_chain_changed(new_chain):
    var val = convert_util.to_GDScript(new_chain[0])
    emit_signal("chain_changed", val)

# Checks if client has Metamask installed
# NOTE - This is not 100% accurate.  Because it is checking a JS property, this can be faked by another wallet provider.
# See https://docs.metamask.io/guide/ethereum-provider.html#ethereum-isconnected for details
func has_metamask() -> bool:
    return _ethereum != null && _ethereum.isMetaMask

# Checks if Metamask can talk to the current chain
func is_network_connected() -> bool:
    return _ethereum.isConnected()

# Requests permission to view user's accounts. Fires request_accounts_finished when complete
# Currently only returns the active account in Metamask, but passes back an Array for future proofing
func request_accounts():
    var request_body = JavaScript.create_object('Object')
    request_body['method'] = 'eth_requestAccounts'
    _ethereum.request(request_body).then(
        _window.callback_handler(_request_success)
    ).catch(
        _window.callback_handler(_request_failed)
    )

func _request_success_callback(_args):
    var last = _window.last_returned_value
    var addresses = convert_util.to_GDScript(last[0])
    emit_signal('request_accounts_finished', addresses, null)

func _request_failed_callback(_args):
    var last = _window.last_returned_value
    var error = convert_util.to_GDScript(last[0])
    emit_signal('request_accounts_finished', null, error)
