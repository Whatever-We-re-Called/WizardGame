extends Node2D

static var handled_startargs = false


func _ready() -> void:
	_handle_startup_args()
	SteamWrapper.invite_received.connect(_online_invite_received)


func _on_play_pressed() -> void:
	%Main.visible = false
	%Play.visible = true


func _on_settings_pressed() -> void:
	pass


func _on_quit_pressed() -> void:
	get_tree().quit()


func _handle_startup_args() -> void:
	if handled_startargs:
		return
	
	var address = "127.0.0.1"
	var port = IPBasedConnection.DEFAULT_PORT
	if StartArgs.has("address"):
		address = StartArgs.get_value("address")
	if StartArgs.has("port"):
		port = StartArgs.get_value("port")
	
	if StartArgs.has("host"):
		if StartArgs.has("delay"):
			var delay = float(StartArgs.get_value("delay")) 
			await get_tree().create_timer(delay).timeout
		
		GameInstance.host_online(func o():
			SessionManager.set_strategy(IPBasedConnection.new(address, int(port)))
			SessionManager.create_server(),
			true
		)
	elif StartArgs.has("join"):
		if StartArgs.has("delay"):
			var delay = float(StartArgs.get_value("delay")) 
			await get_tree().create_timer(delay).timeout
		
		GameInstance.connect_online(func o():
			SessionManager.set_strategy(IPBasedConnection.new(address, int(port)))
			SessionManager.connect_to_server(),
			true
		)
	
	handled_startargs = true


func _online_invite_received(friend_id, lobby_id):
	%Invite.invite_received(friend_id, lobby_id)
