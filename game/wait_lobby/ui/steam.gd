extends MultiplayerScreenButton


func _on_host_pressed():
	SessionManager.set_strategy(SteamBasedStrategy.new())
	SessionManager.create_server()


func _ready():
	if SteamWrapper.is_steam_running():
		screen.get_child(0).theme = load("res://game/wait_lobby/ui/resources/selected_button_theme.tres")


func _on_friends_pressed() -> void:
	var list = preload("res://multiplayer/steam/list/scenes/friend_list.tscn").instantiate()
	screen.get_parent().add_child(list)
