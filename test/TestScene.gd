extends Control

onready var installed_check_box: CheckBox = $PanelSplitContainer/UserPanelContainer/MarginContainer/UserContainer/InstalledCheckBox
onready var connected_check_box: CheckBox = $PanelSplitContainer/UserPanelContainer/MarginContainer/UserContainer/ConnectedCheckBox
onready var user_info_text_edit: TextEdit = $PanelSplitContainer/UserPanelContainer/MarginContainer/UserContainer/UserInfoTextEdit
onready var connect_button: Button = $PanelSplitContainer/UserPanelContainer/MarginContainer/UserContainer/ConnectButton

func _ready():
    # First check if Metamask is installed
    var installed = Metamask.has_metamask()
    installed_check_box.pressed = installed
    if not installed:
        user_info_text_edit.text += "Metamask is not installed...\n"
        _fail_init()
        return
    user_info_text_edit.text += "Metamask is installed...\n"
    var connected = Metamask.is_network_connected()
    connected_check_box.pressed = connected
    if not connected:
        user_info_text_edit.text += "Metamask is not installed...\n"
        _fail_init()
        return
    user_info_text_edit.text += "Metamask is connected...\n"
    Metamask.connect("request_accounts_finished", self, "_on_Metamask_request_accounts_finished")

func _fail_init():
    user_info_text_edit.text += "Aborting remaining checks\n"
    connect_button.disabled = true

func _on_ConnectButton_pressed():
    user_info_text_edit.text += "Attempting Request Accounts\n"
    connect_button.disabled = true
    Metamask.request_accounts()

func _on_Metamask_request_accounts_finished(success, error):
    connect_button.disabled = false
    if error != null:
        # The call failed
        user_info_text_edit.text += "Accounts Request Failed...\n"
        user_info_text_edit.text += "Reason: " + error.message + "\n"
        return
    # The call succeeded
    user_info_text_edit.text += "Accounts Request Succeeded...\n"
    user_info_text_edit.text += "Addresses: "
    for addr in success:
        user_info_text_edit.text += addr
        user_info_text_edit.text += " "
    user_info_text_edit.text += "\n"
