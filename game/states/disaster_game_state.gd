extends GameState

var countdown: float


func _enter():
	var current_disaster = game_scene.current_map_disasters[game_scene.current_disaster_number - 1]
	DisasterManager.set_current_disaster(current_disaster.enum_type)
	DisasterManager.current_disaster.start()
	
	countdown = game_scene.game_manager.game_settings.disaster_duration
	game_scene.map_progress_ui.update_disaster_icons.rpc(game_scene.current_map_disasters, game_scene.current_disaster_number, true)
	game_scene.map_progress_ui.set_current_disaster_text.rpc(game_scene.current_map_disasters[game_scene.current_disaster_number - 1])


func _exit():
	DisasterManager.current_disaster.stop()


func _update(delta):
	if countdown <= 0.0:
		game_scene.transition_to_state("disasterend")
	else:
		countdown -= delta
