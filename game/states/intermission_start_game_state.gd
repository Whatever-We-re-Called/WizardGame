extends GameState


func _enter():
	for player in game_scene.game_manager.players:
		player.kill()
	game_scene.change_to_scene("res://game/intermission/intermission.tscn")
	game_scene.intermission.set_state.rpc(Intermission.State.START)
	await get_tree().create_timer(2.0).timeout
	
	game_scene.transition_to_state("intermissionscoring")
