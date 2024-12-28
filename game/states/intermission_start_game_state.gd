extends GameState


func _enter():
	for player in game_scene.game_manager.players:
		player.kill()
	game_scene.change_to_scene("res://game/intermission/intermission.tscn")
	game_scene.intermission.set_state.rpc(Intermission.State.START)
	await get_tree().create_timer(game_scene.game_manager.game_settings.intermission_start_time).timeout
	
	game_scene.transition_to_state("intermissionscoring")
