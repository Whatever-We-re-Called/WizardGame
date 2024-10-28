extends CanvasLayer



func _on_local_pressed() -> void:
	_load_game_manager()
	SessionManager.set_strategy(LocalBasedConnection.new())
	_remove_self()


func _on_online_pressed() -> void:
	_load_game_manager()
	SessionManager.set_strategy(SteamBasedStrategy.new())
	SessionManager.create_server()
	_remove_self()


func _load_game_manager():
	var game_manager = load("res://game/game_manager.tscn").instantiate()
	get_tree().root.add_child.call_deferred(game_manager)
	
	
func _remove_self():
	get_tree().root.remove_child.call_deferred(self)
	self.queue_free()


func _on_direct_connection_pressed() -> void:
	print("Not yet implemented...")


func _on_back_pressed() -> void:
	%Main.visible = true
	%Play.visible = false
