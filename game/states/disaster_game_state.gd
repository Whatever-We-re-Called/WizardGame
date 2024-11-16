extends GameState

var countdown: float
var current_disaster: DisasterResource


func _enter():
	current_disaster = game_scene.current_map_disasters[game_scene.current_disaster_number - 1]
	DisasterManager.set_current_disaster(current_disaster.enum_type)
	DisasterManager.current_disaster.start()
	
	countdown = game_scene.game_manager.game_settings.disaster_duration
	game_scene.map_progress_ui.update_disaster_icons.rpc(game_scene.current_map_disasters, game_scene.current_disaster_number, true)
	game_scene.map_progress_ui.set_current_disaster_text.rpc(game_scene.current_map_disasters[game_scene.current_disaster_number - 1])


func _exit():
	_handle_survival_scoring_event()
	DisasterManager.current_disaster.stop()


func _update(delta):
	if countdown <= 0.0:
		game_scene.transition_to_state("disasterend")
	else:
		countdown -= delta


func _handle_survival_scoring_event():
	var survived_players: Array[Player]
	for player in game_scene.game_manager.players:
		if not game_scene.dead_players.has(player):
			survived_players.append(player)
	
	game_scene.game_manager.game_scoring.queue_survival_scoring_event(
		survived_players, current_disaster.severity
	)
