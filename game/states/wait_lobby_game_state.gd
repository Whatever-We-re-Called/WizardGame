extends GameState


func _enter():
	game_manager.revive_dead_players.rpc_id(1)
	await game_manager.get_tree().process_frame
	
	game_manager.change_to_scene.rpc_id(1, "res://wait_lobby/wait_lobby.tscn")
	
	game_manager.map_progress_ui.visible = false
