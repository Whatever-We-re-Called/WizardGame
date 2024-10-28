extends Node2D


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
	var address = "127.0.0.1"
	var port = IPBasedConnection.DEFAULT_PORT
	if StartArgs.has("address"):
		address = StartArgs.get_value("address")
	if StartArgs.has("port"):
		port = StartArgs.get_value("port")
	
	if StartArgs.has("host"):
		swap_to_game_manager()
		await get_tree().process_frame
		SessionManager.set_strategy(IPBasedConnection.new(address, int(port)))
		SessionManager.create_server()
		_remove_self()
	elif StartArgs.has("join"):
		swap_to_game_manager()
		await get_tree().process_frame
		SessionManager.set_strategy(IPBasedConnection.new(address, int(port)))
		SessionManager.connect_to_server()
		_remove_self()
		
		
func swap_to_game_manager():
	var game_manager = load("res://game/game_manager.tscn").instantiate()
	get_tree().root.add_child.call_deferred(game_manager)
	
	
func _remove_self():
	get_tree().root.remove_child.call_deferred(self)
	self.queue_free()


func _online_invite_received(friend_id, lobby_id):
	%Invite.invite_received(friend_id, lobby_id)
