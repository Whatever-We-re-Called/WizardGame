extends Node

@onready var buttons = [ $CenterContainer/HBoxContainer/IP, $CenterContainer/HBoxContainer/Steam, $CenterContainer/HBoxContainer/Local ]

# Called when the node enters the scene tree for the first time.
func _ready():
	self.visible = true
	
	for button in buttons:
		button.pressed.connect(_update_button.bind(button))
	_update_button(null)
	SessionManager.serverbound_client_connected_to_server.connect(on_connect)
	SessionManager.client_connection_failed.connect(on_fail)
	SessionManager.session_added.connect(_on_session_added)
	
	if StartArgs.has("host"):
		buttons[0]._on_host_pressed() # IP based hosting
	elif StartArgs.has("join"):
		buttons[0]._on_join_pressed() # IP based joining
	
	
func _process(delta):
	if SessionManager.is_connected_to_peer():
		$Disconnect.visible = true
	else:
		$Disconnect.visible = false
	
	
func _update_button(selected):
	if selected != null and selected.theme != null:
		return
	for button in buttons:
		button.theme = null
		button.screen.visible = false
	if selected:
		selected.screen.visible = true


func on_connect(id):
	if SessionManager.debug:
		print("Client connected: ", id)
	
func on_fail():
	if SessionManager.debug:
		print("Connection failed")


func _on_disconnect_pressed():
	SessionManager.disconnect_client()
	SessionManager.close_server()


func _on_users_pressed():
	print("Users: ", SessionManager.connected_clients)
	
	
func _on_local_pressed():
	SessionManager.set_strategy(LocalBasedConnection.new())


func _on_toggle_ui_pressed():
	$CenterContainer.visible = not $CenterContainer.visible
	$LocalScreen.visible = false if not $CenterContainer.visible else $CenterContainer/HBoxContainer/Local.theme != null
	$IPScreen.visible = false if not $CenterContainer.visible else $CenterContainer/HBoxContainer/IP.theme != null
	$SteamScreen.visible = false if not $CenterContainer.visible else $CenterContainer/HBoxContainer/Steam.theme != null
	

func _on_session_added(data):
	if data.peer_id == 1 and $CenterContainer.visible:
		_on_toggle_ui_pressed()
