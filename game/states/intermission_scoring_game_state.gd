extends GameState


func _enter():
	game_scene.intermission.set_state(Intermission.State.SCORING)
	
	await get_tree().process_frame
	game_scene.transition_to_state("mapstart")
