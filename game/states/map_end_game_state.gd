extends GameState

var countdown: float


func _enter():
	countdown = game_manager.game_settings.time_after_last_disaster
	
	game_manager.map_progress_ui.update_disaster_icons.rpc(game_manager.current_map_disasters, game_manager.current_disaster_number + 1, false)


func _update(delta):
	if countdown <= 0.0:
		game_manager.transition_to_state("intermission")
	else:
		game_manager.map_progress_ui.set_countdown_to_intermission_text.rpc(ceil(countdown))
		countdown -= delta
