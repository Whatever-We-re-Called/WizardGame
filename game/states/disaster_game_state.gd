extends GameState

var countdown: float


func _enter():
	print("Disaster started!")
	# TODO Spawn disaster
	var current_disaster = game_manager.game_settings.disaster_pool[game_manager.current_disaster_number - 1]
	DisasterManager.set_current_disaster(current_disaster.enum_type)
	DisasterManager.current_disaster.start()
	
	countdown = game_manager.game_settings.disaster_duration
	game_manager.map_progress_ui.update_disaster_icons.rpc(game_manager.game_settings.disaster_pool, game_manager.current_disaster_number, true)
	game_manager.map_progress_ui.set_current_disaster_text.rpc(game_manager.game_settings.disaster_pool[game_manager.current_disaster_number - 1])


func _update(delta):
	if countdown <= 0.0:
		game_manager.transition_to_state("disasterend")
	else:
		countdown -= delta


func _is_last_disaster() -> bool:
	return game_manager.current_disaster_number == game_manager.game_settings.disaster_pool.size()
