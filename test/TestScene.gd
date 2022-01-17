extends Control

onready var installed_check_box: CheckBox = $PanelSplitContainer/UserPanelContainer/MarginContainer/UserContainer/InstalledCheckBox
onready var connected_check_box: CheckBox = $PanelSplitContainer/UserPanelContainer/MarginContainer/UserContainer/ConnectedCheckBox
onready var connect_button: Button = $PanelSplitContainer/UserPanelContainer/MarginContainer/UserContainer/ConnectButton
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
    # Connect signals
    Metamask.connect("request_accounts_finished", self, "_on_Metamask_request_accounts_finished")
    Metamask.connect("accounts_changed", self, "_on_Metamask_accounts_changed")
    Metamask.connect("chain_changed", self, "_on_Metamask_chain_changed")

func _print(text: String):
    output_text_edit.text += text + "\n"

func _fail_init():
    _print("Aborting remaining checks")
    connect_button.disabled = true

func _on_ConnectButton_pressed():
    _print("Attempting Request Accounts")
    connect_button.disabled = true
    Metamask.request_accounts()

func _on_Metamask_request_accounts_finished(success, error):
    connect_button.disabled = false
    if error != null:
        # The call failed
        _print("Accounts Request Failed...")
        _print("Reason: " + error.message)
        return
    # The call succeeded
    _print("Accounts Request Succeeded...")
    _print("Addresses:")
    for addr in success:
        _print("\t" + addr)

func _on_Metamask_accounts_changed(new_accounts):
    _print("User Accounts Changed To " + new_accounts[0])

func _on_Metamask_chain_changed(new_chain_id):
    _print("User Connected Chain Changed To " + new_chain_id)
