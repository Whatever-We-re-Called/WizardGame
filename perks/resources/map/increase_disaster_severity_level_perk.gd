extends PerkExecution


func _on_activate():
	game_manager.game_settings.map_disaster_severity += 5


func _on_deactivate():
	game_manager.game_settings.map_disaster_severity -= 5
