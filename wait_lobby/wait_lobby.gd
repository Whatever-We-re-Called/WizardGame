class_name WaitLobby extends PlayableScene


func _on_start_interactable_interacted(player: Player) -> void:
	for i in range(10):
		test.rpc(i)
	#game_manager.try_to_start_game()


func _on_settings_interactable_interacted(player: Player) -> void:
	if game_manager.game_settings_ui.visible == true: return
	
	game_manager.toggle_game_settings()
	player.controller.freeze_input = true
	await game_manager.game_settings_ui.closed
	
	game_manager.toggle_game_settings()
	player.controller.freeze_input = false


@rpc("any_peer", "unreliable")
func test(val):
	print(val)
