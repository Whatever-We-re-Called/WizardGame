extends GameState


func _enter():
	if SessionManager.is_playing_local():
		# TODO
		pass
	else:
		game_scene.intermission.set_state.rpc(Intermission.State.MODIFYING_ONLINE)
		game_scene.intermission.modifying_online_ui.setup_on_server()
