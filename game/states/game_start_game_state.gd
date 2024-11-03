extends GameState


func _enter():
	game_scene.game_manager.scores = {}
	game_scene.player_score_ui.update(game_scene.game_manager.players, game_scene.game_manager.scores)
	
	await get_tree().process_frame
	game_scene.transition_to_state("mapstart")
