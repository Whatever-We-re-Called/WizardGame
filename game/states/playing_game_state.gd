extends GameState


func _enter():
	game_manager.load_random_map.rpc_id(1)
	
	game_manager.map_progress_ui.visible = true
	game_manager.map_progress_ui.countdown_to_next_disaster(game_manager.game_settings.time_before_first_disaster, true)
	game_manager.map_progress_ui.update_disaster_icons(game_manager.game_settings.disaster_pool, 1, false)
