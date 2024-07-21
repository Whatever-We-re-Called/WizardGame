extends ScreenButton


func _on_host_pressed():
	SessionManager.set_strategy(SteamBasedStrategy.new())
	SessionManager.create_server()


func _ready():
	if Steam.isSteamRunning():
		screen.get_child(0).theme = load("res://multiplayer/example_scene/ui/resources/selected_button_theme.tres")
