extends GameManagerModule

func _ready():
	if SessionManager.connection_strategy is LocalBasedConnection:
		update_player_info()


func _handshake_init(handshake: HandshakeInstance):
	handshake.handshake_complete.connect(update_player_info.bind(handshake.data))


func _non_handshake_connect(data):
	if game_manager.is_host_or_local(data):
		update_player_info(data)


func toggle_game_settings():
	if multiplayer.is_server():
		if %GameSettingsUI.visible == false:
			%GameSettingsUI.populate(game_manager.game_settings)
			%GameSettingsUI.visible = true
		else:
			game_manager.game_settings = %GameSettingsUI.get_game_settings().duplicate()
			%GameSettingsUI.visible = false


func is_game_settings_ui_visible() -> bool:
	return %GameSettingsUI.visible


func update_player_info(_data = null):
	await get_tree().process_frame
	for child in %PlayerInfoUI/HBoxContainer.get_children():
		child.queue_free()
		
	for player in game_manager.players:
		var info = preload("res://game/ui/player_info/player_info.tscn").instantiate()
		info.set_player(player)
		if SessionManager.connection_strategy is SteamBasedStrategy:
			info.set_state(PlayerInfoUI.State.OnlinePlayer)
		else:
			info.set_state(PlayerInfoUI.State.LocalPlayer)
			
		%PlayerInfoUI/HBoxContainer.add_child(info)
			
	if is_multiplayer_authority() and not SessionManager.connection_strategy is IPBasedConnection:
		var info2 = preload("res://game/ui/player_info/player_info.tscn").instantiate()
		info2.set_player(game_manager.get_player_from_peer_id(1))
		if SessionManager.connection_strategy is LocalBasedConnection:
			info2.set_state(PlayerInfoUI.State.Join)
		else:
			info2.set_state(PlayerInfoUI.State.Invite)
			
		%PlayerInfoUI/HBoxContainer.add_child(info2)
