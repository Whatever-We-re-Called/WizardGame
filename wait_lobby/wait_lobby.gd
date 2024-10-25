class_name WaitLobby extends PlayableScene


func _on_start_interactable_interacted() -> void:
	game_manager.try_to_start_game()
