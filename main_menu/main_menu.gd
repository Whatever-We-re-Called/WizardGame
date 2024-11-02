extends Node2D

static var handled_startargs = false


func _ready() -> void:
	_handle_startup_args()
	print("Main")
	SteamWrapper.invite_received.connect(_online_invite_received)
	
	print("Main 2")
	$Main/Play.disabled = true
	$Main/Settings.disabled = true
	$Main/Quit.disabled = true
	await get_tree().process_frame
	$Main/Play.disabled = false
	$Main/Settings.disabled = false
	$Main/Quit.disabled = false
	print("Main 3")


func _on_play_pressed() -> void:
	print("Play")
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
