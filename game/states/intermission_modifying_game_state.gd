extends GameState


func _enter():
	if SessionManager.is_playing_local():
		# TODO
		pass
	else:
		for player in game_scene.game_manager.players:
			player.spell_inventory.add_runes(10)
		game_scene.intermission.set_state.rpc(Intermission.State.MODIFYING_ONLINE)
		game_scene.intermission.modifying_online_ui.setup_on_server()
		await game_scene.intermission.modifying_online_ui.all_players_readied
		
		game_scene.transition_to_state("intermissionend")
