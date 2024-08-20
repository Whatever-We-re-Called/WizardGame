extends GameState


func _enter():
	print("disaster end enter")
	DisasterManager.current_disaster.stop()
	game_manager.current_disaster_number += 1
	game_manager.increment_scores()
	game_manager.player_score_ui.update(game_manager.players, game_manager.scores)
	
	await get_tree().process_frame
	if _is_last_disaster():
		game_manager.transition_to_state("mapend")
	else:
		game_manager.transition_to_state("disasterstart")


func _is_last_disaster() -> bool:
	return game_manager.current_disaster_number == game_manager.game_settings.disaster_pool.size()
