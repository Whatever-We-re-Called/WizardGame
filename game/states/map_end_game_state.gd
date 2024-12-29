extends GameState

var countdown: float


func _enter():
	game_scene.game_manager.perks_manager.increment_player_perk_pool_strengths()
	
	countdown = game_scene.game_manager.game_settings.time_after_last_disaster
	game_scene.game_manager.perks_manager.perform_deactivation_event(Perk.DeactivationEvent.ON_MAP_END)
	
	game_scene.map_progress_ui.update_disaster_icons.rpc(game_scene.current_map_disasters, game_scene.current_disaster_number + 1, false)



func _exit():
	game_scene.map_progress_ui.visible = false


func _update(delta):
	if countdown <= 0.0:
		game_scene.transition_to_state("intermissionstart")
	else:
		game_scene.map_progress_ui.set_countdown_to_intermission_text.rpc(ceil(countdown))
		countdown -= delta
