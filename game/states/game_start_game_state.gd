extends GameState


func _enter():
	print("game start enter")
	game_manager.scores = {}
	game_manager.player_score_ui.update(game_manager.players, game_manager.scores)
	
	await get_tree().process_frame
	game_manager.transition_to_state("mapstart")
