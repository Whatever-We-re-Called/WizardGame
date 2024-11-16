extends GameState


func _enter():
	game_scene.intermission.set_state.rpc(Intermission.State.SCORING)
	_init_player_score_cards()
	
	#await get_tree().create_timer(5.0).timeout
	#game_scene.transition_to_state("mapstart")


func _init_player_score_cards():
	for player in game_scene.game_manager.players:
		game_scene.intermission.scoring_ui.create_player_score_card.rpc(
			player.peer_id,
			player.name,
			game_scene.game_manager.scores[player],
			game_scene.game_manager.game_settings.goal_score
		)
