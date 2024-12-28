extends GameState


func _enter():
	game_scene.intermission.set_state.rpc(Intermission.State.END)
	game_scene.intermission.end_ui.generate_perk_warnings()
	await get_tree().create_timer(2.0).timeout
	
	game_scene.transition_to_state("mapstart")
