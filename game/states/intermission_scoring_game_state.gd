extends GameState


func _enter():
	game_scene.intermission.set_state.rpc(Intermission.State.SCORING)
	
	await get_tree().create_timer(5.0).timeout
	game_scene.transition_to_state("mapstart")
