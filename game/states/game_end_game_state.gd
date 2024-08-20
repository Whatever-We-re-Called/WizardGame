extends GameState


func _enter():
	await get_tree().process_frame
	game_manager.transition_to_state("resultscreen")
