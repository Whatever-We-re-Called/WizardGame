extends GameState


func _enter():
	game_scene.intermission.set_state.rpc(Intermission.State.RESULTS)
	
	game_scene.intermission.result_ui.setup.rpc()
	_init_player_result_cards()


func _init_player_result_cards():
	var player_placements = game_scene.game_manager.game_scoring.get_player_placements()
	for player in player_placements:
		var placement = player_placements[player]
		game_scene.intermission.result_ui.create_player_result_card.rpc(
			player.name,
			placement,
			game_scene.game_manager.game_scoring.get_player_score(player)
		)
