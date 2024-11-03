extends CanvasLayer


func _on_local_pressed() -> void:
	GameInstance.connect_local()


func _on_online_pressed() -> void:
	GameInstance.host_online(func o():
		SessionManager.set_strategy(SteamBasedStrategy.new())
		SessionManager.create_server()
	)


func _on_direct_connection_pressed() -> void:
	print("Not yet implemented...")


func _on_back_pressed() -> void:
	%Main.visible = true
	%Play.visible = false
	%Play/CenterContainer/HBoxContainer/Online.disabled = false
	%Play/CenterContainer/HBoxContainer/Online/OnlineDisconnected.visible = false
	
	%Main/Play.grab_focus()
