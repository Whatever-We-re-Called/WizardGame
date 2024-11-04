extends GameState


func _enter():
	await get_tree().process_frame
	game_scene.transition_to_state("mapstart")
