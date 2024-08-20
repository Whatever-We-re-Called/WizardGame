extends GameState


func _enter():
	game_manager.change_to_scene.rpc_id(1, "res://game/wait_lobby/wait_lobby.tscn")
	game_manager.scores = {}
	game_manager.player_score_ui.visible = false


func _exit():
	game_manager.player_score_ui.update(game_manager.players, game_manager.scores)
