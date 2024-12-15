extends PerkExecution


func _on_activate():
	game_manager.game_settings.map_disaster_severity += PERK_DATA.map_disaster_severity_increase_amount


func _on_deactivate():
	game_manager.game_settings.map_disaster_severity -= PERK_DATA.map_disaster_severity_increase_amount
