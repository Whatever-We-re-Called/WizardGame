extends GameState


func _enter():
	game_scene.intermission.set_state.rpc(Intermission.State.SPELLBOOK)
	
	if SessionManager.is_playing_local():
		game_scene.intermission.spellbook_ui.setup_local()
		await get_tree().create_timer(2.5).timeout
	else:
		game_scene.intermission.spellbook_ui.setup_online()
		await game_scene.intermission.spellbook_ui.finished
	
	game_scene.transition_to_state("intermissionend")
