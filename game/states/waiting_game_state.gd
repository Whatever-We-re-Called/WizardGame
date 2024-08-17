extends GameState


func _enter():
	game_manager.change_to_scene.rpc_id(1, preload("res://game/wait_lobby/wait_lobby.tscn"))
