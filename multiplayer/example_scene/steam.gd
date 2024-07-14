extends Button


func _on_host_pressed():
	SessionManager.set_strategy(SteamBasedStrategy.new())
	SessionManager.create_server()
