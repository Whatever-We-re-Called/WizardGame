extends GameState


func _enter():
	game_scene.game_manager.game_scoring.reset()
	game_scene.game_manager.perks_manager.reset_player_perk_pool_strengths()
	
	await get_tree().process_frame
	game_scene.transition_to_state("mapstart")
