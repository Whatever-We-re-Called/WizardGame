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


func _exit():
	DisasterManager.current_disaster.stop()
	game_manager.current_disaster_number += 1
	game_manager.increment_scores()
	game_manager.player_score_ui.update.rpc(game_manager.players, game_manager.scores)


func _update(delta):
	if countdown <= 0.0:
		if _is_last_disaster():
			game_manager.transition_to_state("mapend")
		else:
			game_manager.transition_to_state("disastercountdown")
	else:
		countdown -= delta


func _is_last_disaster() -> bool:
	return game_manager.current_disaster_number == game_manager.game_settings.disaster_pool.size()
