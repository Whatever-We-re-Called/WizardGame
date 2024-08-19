extends GameState


func _enter():
	game_manager.load_random_map.rpc_id(1)
	
	game_manager.current_disaster_number = 1
	# TODO Make randomized disaster list
	
	game_manager.map_progress_ui.visible = true
	game_manager.player_score_ui.visible = true
	
	await get_tree().process_frame
	game_manager.transition_to_state("disastercountdown")
