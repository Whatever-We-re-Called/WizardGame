extends Node

@onready var game_manager = get_parent() as GameManager
@onready var pause_menu: CanvasLayer = %PauseMenu


func _ready() -> void:
	pause_menu.visible = false


func _process(delta: float) -> void:
	for player in game_manager.players:
		if Input.is_action_just_pressed(player.im.pause):
			toggle_pause()


func toggle_pause():
	if SessionManager.is_playing_local():
		_toggle_pause_local()
	else:
		_toggle_pause_online()


func _toggle_pause_online():
	var source_peer_id = SessionManager.get_self_peer_id()
	var source_player = game_manager.get_player_from_peer_id(source_peer_id)
	
	if pause_menu.visible == false:
		_enable_pause_menu(true)
		source_player.controller.freeze_input = true
	else:
		_enable_pause_menu(false)
		source_player.controller.freeze_input = false


func _toggle_pause_local():
	if pause_menu.visible == false:
		_enable_pause_menu(true)
		game_manager.get_tree().paused = true
	else:
		_enable_pause_menu(false)
		game_manager.get_tree().paused = false


func _enable_pause_menu(enabled: bool):
	pause_menu.visible = enabled
	
	if enabled == true:
		%ResumeButton.grab_focus()


func _on_resume_button_pressed() -> void:
	toggle_pause()


func _on_settings_button_pressed() -> void:
	# TODO
	pass


func _on_wait_lobby_button_pressed() -> void:
	toggle_pause()
	game_manager.return_to_wait_lobby()


func _on_main_menu_button_pressed() -> void:
	toggle_pause()
	SessionManager.disconnect_client()
