extends GameState


func _enter():
	game_manager.change_to_scene.rpc_id(1, "res://game/wait_lobby/wait_lobby.tscn")
	
	game_manager.map_progress_ui.visible = false
