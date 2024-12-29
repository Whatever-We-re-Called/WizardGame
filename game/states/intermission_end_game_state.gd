extends GameState


func _enter():
	game_scene.game_manager.perks_manager.increment_player_perk_pool_strengths()
	
	game_scene.intermission.set_state.rpc(Intermission.State.END)
	game_scene.intermission.end_ui.generate_perk_warnings()
	await get_tree().create_timer(game_scene.game_manager.game_settings.intermission_end_time).timeout
	
	game_scene.transition_to_state("mapstart")
