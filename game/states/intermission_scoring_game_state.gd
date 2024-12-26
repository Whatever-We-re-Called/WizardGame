extends GameState


func _enter():
	game_scene.intermission.set_state.rpc(Intermission.State.SCORING)
	_init_player_score_cards()
	await _execute_scoring_events()
	
	if _has_player_reached_goal_score():
		game_scene.transition_to_state("intermissionresults")
	else:
		game_scene.transition_to_state("intermissionspellbook")


func _init_player_score_cards():
	for player in game_scene.game_manager.players:
		game_scene.intermission.scoring_ui.create_player_score_card.rpc(
			player.peer_id,
			player.name,
			game_scene.game_manager.game_scoring.get_player_score(player),
			game_scene.game_manager.game_settings.goal_score
		)


func _execute_scoring_events():
	game_scene.intermission.scoring_ui.clear_scoring_event_text.rpc()
	await get_tree().create_timer(1.0).timeout
	
	var queued_scoring_events = game_scene.game_manager.game_scoring.queued_scoring_events
	while not queued_scoring_events.is_empty():
		var scoring_event = queued_scoring_events.dequeue()
		var scoring_event_text_subtitle =\
			"+{0} Point".format([str(scoring_event.rewarded_score)])\
			+ ("s" if scoring_event.rewarded_score > 1 else "")
		
		game_scene.intermission.scoring_ui.set_scoring_event_text.rpc(
			scoring_event.title,
			scoring_event_text_subtitle,
			scoring_event.color)
		for player in scoring_event.rewarded_players:
			game_scene.game_manager.game_scoring.add_player_score(
				player, scoring_event.rewarded_score)
			game_scene.intermission.scoring_ui.update_player_score_card.rpc(
				player.peer_id,
				game_scene.game_manager.game_scoring.get_player_score(player))
		await get_tree().create_timer(1.0).timeout
		
		game_scene.intermission.scoring_ui.clear_scoring_event_text.rpc()
		await get_tree().create_timer(0.5).timeout


func _has_player_reached_goal_score() -> bool:
	var highest_score = game_scene.game_manager.game_scoring.get_highest_player_score()
	var goal_score = game_scene.game_manager.game_settings.goal_score
	return highest_score >= goal_score
