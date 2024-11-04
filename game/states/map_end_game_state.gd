extends GameState

var countdown: float


func _enter():
	countdown = game_scene.game_manager.game_settings.time_after_last_disaster
	
	game_scene.map_progress_ui.update_disaster_icons.rpc(game_scene.current_map_disasters, game_scene.current_disaster_number + 1, false)


func _update(delta):
	if countdown <= 0.0:
		game_scene.transition_to_state("intermissionstart")
	else:
		game_scene.map_progress_ui.set_countdown_to_intermission_text.rpc(ceil(countdown))
		countdown -= delta
