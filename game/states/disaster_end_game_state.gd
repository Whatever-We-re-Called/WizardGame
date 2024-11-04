extends GameState


func _enter():
	game_scene.increment_scores()
	game_scene.player_score_ui.update(game_scene.game_manager.players, game_scene.game_manager.scores)
	
	await get_tree().process_frame
	if _is_last_disaster():
		game_scene.transition_to_state("mapend")
	else:
		game_scene.current_disaster_number += 1
		game_scene.transition_to_state("disasterstart")


func _is_last_disaster() -> bool:
	return game_scene.current_disaster_number == game_scene.current_map_disasters.size()
