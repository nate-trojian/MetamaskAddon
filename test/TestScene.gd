extends Control

# System Checks
onready var installed_check_box: CheckBox = $PanelSplitContainer/UserPanelContainer/MarginContainer/UserContainer/InstalledCheckBox
onready var connected_check_box: CheckBox = $PanelSplitContainer/UserPanelContainer/MarginContainer/UserContainer/ConnectedCheckBox
onready var connect_button: Button = $PanelSplitContainer/UserPanelContainer/MarginContainer/UserContainer/ConnectButton
# Switching Chains
onready var chain_id_line_edit: LineEdit = $PanelSplitContainer/UserPanelContainer/MarginContainer/UserContainer/ChainIdLineEdit
onready var switch_chain_button: Button = $PanelSplitContainer/UserPanelContainer/MarginContainer/UserContainer/SwitchChainButton
# Eth Balance
onready var balance_line_edit: LineEdit = $PanelSplitContainer/UserPanelContainer/MarginContainer/UserContainer/BalanceLineEdit
onready var balance_button: Button = $PanelSplitContainer/UserPanelContainer/MarginContainer/UserContainer/BalanceButton
# Token Balance
onready var token_balance_line_edit: LineEdit = $PanelSplitContainer/UserPanelContainer/MarginContainer/UserContainer/TokenBalanceAddressLineEdit
onready var wallet_token_line_edit: LineEdit = $PanelSplitContainer/UserPanelContainer/MarginContainer/UserContainer/WalletTokenBalanceLineEdit
onready var token_balance_button: Button = $PanelSplitContainer/UserPanelContainer/MarginContainer/UserContainer/TokenBalanceButton
# Custom Chain
onready var add_binance_button: Button = $PanelSplitContainer/UserPanelContainer/MarginContainer/UserContainer/AddBinanceButton
onready var add_matic_button: Button = $PanelSplitContainer/UserPanelContainer/MarginContainer/UserContainer/AddMaticButton
# Custom Token
onready var add_enjin_token_button: Button = $PanelSplitContainer/UserPanelContainer/MarginContainer/UserContainer/AddEnjinTokenButton
# Gas Price
onready var get_gas_button: Button = $PanelSplitContainer/UserPanelContainer/MarginContainer/UserContainer/GetGasButton
# Transfer ERC20
onready var transfer_from_line_edit: LineEdit = $PanelSplitContainer/UserPanelContainer/MarginContainer/UserContainer/TransferFromLineEdit
onready var transfer_token_line_edit: LineEdit = $PanelSplitContainer/UserPanelContainer/MarginContainer/UserContainer/TransferTokenLineEdit
onready var transfer_to_line_edit: LineEdit = $PanelSplitContainer/UserPanelContainer/MarginContainer/UserContainer/TransferToLineEdit
onready var transfer_button: Button = $PanelSplitContainer/UserPanelContainer/MarginContainer/UserContainer/TransferButton
onready var transfer_amount_line_edit: LineEdit = $PanelSplitContainer/UserPanelContainer/MarginContainer/UserContainer/TransferAmountLineEdit
# Output
onready var output_text_edit: TextEdit = $PanelSplitContainer/OutputPanelContainer/MarginContainer/VBoxContainer/OutputTextEdit

func _ready():
    # First check if Metamask is installed
    var installed = Metamask.has_metamask()
    installed_check_box.pressed = installed
    if not installed:
        _print("Metamask is not installed...")
        _fail_init()
        return
    _print("Metamask is installed...")
    # Check if Metamask is connected
    var connected = Metamask.is_network_connected()
    connected_check_box.pressed = connected
    if not connected:
        _print("Metamask is not connected...")
        _fail_init()
        return
    _print("Metamask is connected...")
    # Get information on Metamask connection
    _print("Current Chain: " + Metamask.current_chain())
    _print("Connected Account: " + str(Metamask.selected_account()))
    get_client_version()
    # Connect signals
# warning-ignore:return_value_discarded
    Metamask.connect("request_accounts_finished", self, "_on_Metamask_request_accounts_finished")
# warning-ignore:return_value_discarded
    Metamask.connect("accounts_changed", self, "_on_Metamask_accounts_changed")
# warning-ignore:return_value_discarded
    Metamask.connect("chain_changed", self, "_on_Metamask_chain_changed")
# warning-ignore:return_value_discarded
    Metamask.connect("switch_chain_finished", self, "_on_Metamask_switch_chain_finished")
# warning-ignore:return_value_discarded
    Metamask.connect("chain_connected", self, "_on_Metamask_chain_connected")
# warning-ignore:return_value_discarded
    Metamask.connect("chain_disconnected", self, "_on_Metamask_chain_disconnected")
# warning-ignore:return_value_discarded
    Metamask.connect("message_received", self, "_on_Metamask_message_received")
# warning-ignore:return_value_discarded
    Metamask.connect("wallet_balance_finished", self, "_on_Metamask_wallet_balance_finished")
# warning-ignore:return_value_discarded
    Metamask.connect("token_balance_finished", self, "_on_Metamask_token_balance_finished")
# warning-ignore:return_value_discarded
    Metamask.connect("add_eth_chain_finished", self, "_on_Metamask_add_eth_chain_finished")
# warning-ignore:return_value_discarded
    Metamask.connect("add_custom_token_finished", self, "_on_Metamask_add_custom_token_finished")
# warning-ignore:return_value_discarded
    Metamask.connect("send_token_finished", self, "_on_Metamask_send_token_finished")

func _print(text: String):
    output_text_edit.text += text + "\n"

func _fail_init():
    _print("Aborting remaining checks")
    connect_button.disabled = true

# Example of inline handling of the signal from an RPC call
func get_client_version():
    Metamask.client_version()
    var response = yield(Metamask, "client_version_finished")
    if response.error != null:
        # The call failed
        _print("Client Version Request Failed...")
        _print("Reason: " + response.error.message)
        return
    # The call succeeded
    _print("Client Version: " + response.result)

func _on_ConnectButton_pressed():
    _print("Attempting Request Accounts")
    connect_button.disabled = true
    Metamask.request_accounts()

func _on_Metamask_request_accounts_finished(response):
    connect_button.disabled = false
    if response.error != null:
        # The call failed
        _print("Accounts Request Failed...")
        _print("Reason: " + response.error.message)
        return
    # The call succeeded
    _print("Accounts Request Succeeded...")
    _print("Addresses:")
    for addr in response.result:
        _print("\t" + addr)

func _on_Metamask_accounts_changed(new_accounts):
    _print("User Accounts changed to " + new_accounts[0])

func _on_Metamask_chain_changed(new_chain_id):
    _print("User Connected Chain changed to " + new_chain_id)

func _on_Metamask_chain_connected(chain_id):
    _print("Metamask connected to chain: " + chain_id)

func _on_Metamask_chain_disconnected(error):
    _print("Metamask was disconnected from current chain")
    _print("Reason: " + error.message)

func _on_Metamask_message_received(message):
    _print("Metamask received message of type " + message.type)
    _print("Message : " + str(message.data))

func _on_SwitchChainButton_pressed():
    var new_chain_id = chain_id_line_edit.text
    _print("Attempting to Switch Chain to " + new_chain_id)
    switch_chain_button.disabled = true
    Metamask.switch_to_chain(new_chain_id)

func _on_Metamask_switch_chain_finished(response):
    switch_chain_button.disabled = false
    if response.error != null:
        _print("Chain Switch Failed...")
        _print("Reason: " + response.error.message)
        return
    _print("Chain Switch Succeeded...")

func _on_BalanceButton_pressed():
    var addr = balance_line_edit.text
    _print("Attempting to get balance of wallet at " + addr)
    balance_button.disabled = true
    Metamask.wallet_balance(addr)

func _on_Metamask_wallet_balance_finished(response):
    balance_button.disabled = false
    if response.error != null:
        _print("Wallet Balance Failed...")
        _print("Reason: " + response.error.message)
        return
    _print("Wallet Balance Succeeded...")
    # Whatever operations you wish to do with the balance (like aggregate wallet balances)
    # it's better to do it all in Wei, then when you want to display it convert it to a friendlier amount
    var wei_balance = response.result
    var eth_balance = Metamask.convert_util.convert_wei(wei_balance, Metamask.convert_util.Wei.to_Eth)
    _print("Wallet balance - " + str(eth_balance) + " eth")

func _on_TokenBalanceButton_pressed():
    var token_address = token_balance_line_edit.text
    var wallet_address = wallet_token_line_edit.text
    token_balance_button.disabled = true
    Metamask.token_balance(token_address, wallet_address)

func _on_Metamask_token_balance_finished(response):
    token_balance_button.disabled = false
    if response.error != null:
        _print("Token Balance Failed...")
        _print("Reason: " + response.error.message)
        return
    _print("Token Balance Succeeded...")
    _print("Token Balance - " + str(response.result))

func _on_AddBinanceButton_pressed():
    add_binance_button.disabled = true
    # Required variables
    var chain_id = '0x38' # 56 in hex
    var chain_name = 'Binance Smart Chain Mainnet'
    var rpc_url = 'https://bsc-dataseed1.binance.org'
    # Optional variables
    var currency_symbol = 'BNB'
    var blockscan_url = 'https://bscscan.com'
    Metamask.add_eth_chain(chain_id, chain_name, rpc_url, currency_symbol, blockscan_url)

func _on_AddMaticButton_pressed():
    add_matic_button.disabled = true
    # Required variables
    var chain_id = '0x89' # 137 in hex
    var chain_name = 'Matic Mainnet'
    var rpc_url = 'https://polygon-rpc.com/'
    # Optional variables
    var currency_symbol = 'MATIC'
    var blockscan_url = 'https://polygonscan.com/'
    Metamask.add_eth_chain(chain_id, chain_name, rpc_url, currency_symbol, blockscan_url)

func _on_Metamask_add_eth_chain_finished(response):
    add_binance_button.disabled = false
    add_matic_button.disabled = false
    if response.error != null:
        _print("Add Eth Chain Failed...")
        _print("Reason: " + response.error.message)
        return
    _print("Add Eth Chain Succeeded...")

func _on_AddEnjinTokenButton_pressed():
    add_enjin_token_button.disabled = true
    var token_address: String = '0xf629cbd94d3791c9250152bd8dfbdf380e2a3b9c'
    var token_symbol: String = 'ENJ'
    var image_url: String = 'https://cryptologos.cc/logos/enjin-coin-enj-logo.png'
    Metamask.add_custom_token(token_address, token_symbol, image_url)

func _on_Metamask_add_custom_token_finished(response):
    add_enjin_token_button.disabled = false
    if response.error != null:
        _print("Add Custom Token Failed...")
        _print("Reason: " + response.error.message)
        return
    _print("Add Custom Token Succeeded...")
    _print("Add Custom Token - " + str(response.result))

func _on_GetGasButton_pressed():
    get_gas_button.disabled = true
    Metamask.current_gas_price()
    var response = yield(Metamask, "current_gas_price_finished")
    if response.error != null:
        _print("Get Gas Price Failed...")
        _print("Reason: " + response.error.message)
        return
    var gwei_gas = Metamask.convert_util.convert_wei(response.result, Metamask.convert_util.Wei.to_Gwei)
    _print("Current Gas Price = %d gwei" % gwei_gas)
    get_gas_button.disabled = false
    

func _on_TransferButton_pressed():
    transfer_button.disabled = true
    var from = transfer_from_line_edit.text
    var token = transfer_token_line_edit.text
    var recipient = transfer_to_line_edit.text
    var amount = int(transfer_amount_line_edit.text)
    Metamask.send_token(from, token, recipient, amount)

func _on_Metamask_send_token_finished(response):
    transfer_button.disabled = false
    if response.error != null:
        _print("Send Token Failed...")
        _print("Reason: " + response.error.message)
        return
    _print("Send Token Succeeded...")
    _print("Transaction Hash - " + str(response.result))
