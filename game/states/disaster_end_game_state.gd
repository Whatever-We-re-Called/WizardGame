extends GameState


func _enter():
	print("disaster end enter")
	DisasterManager.current_disaster.stop()
	game_manager.current_disaster_number += 1
	game_manager.increment_scores()
	game_manager.player_score_ui.update(game_manager.players, game_manager.scores)
	
	await get_tree().process_frame
	if _has_player_won():
		game_manager.transition_to_state("gameend")
	elif _is_last_disaster():
		game_manager.transition_to_state("mapend")
	else:
		game_manager.transition_to_state("disasterstart")


func _has_player_won() -> bool:
	for player in game_manager.scores:
		var score = game_manager.scores[player]
		
		if score >= game_manager.game_settings.survivals_goal:
			return true
	
	return false


func _is_last_disaster() -> bool:
	return game_manager.current_disaster_number == game_manager.game_settings.disaster_pool.size()
