extends GameState


func _enter():
	game_scene.change_to_scene.rpc_id(1, "res://wait_lobby/wait_lobby.tscn")
	await game_scene.get_tree().process_frame
	game_scene.revive_dead_players.rpc_id(1)
	
	game_scene.map_progress_ui.visible = false
