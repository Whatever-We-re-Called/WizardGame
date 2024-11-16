extends GameState


func _enter():
	game_scene.game_manager.game_scoring.reset()
	
	await get_tree().process_frame
	game_scene.transition_to_state("mapstart")
