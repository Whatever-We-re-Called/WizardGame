extends ScreenButton


func _on_host_pressed():
	SessionManager.set_strategy(SteamBasedStrategy.new())
	SessionManager.create_server()


func _ready():
	if Steam.isSteamRunning():
		$Host.theme = load("res://multiplayer/example_scene/resources/selected_button_theme.tres")
