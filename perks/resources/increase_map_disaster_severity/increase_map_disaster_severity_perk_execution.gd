extends PerkExecution

const INCREASE_AMOUNT = 5


func _on_activate():
	print("A")
	game_manager.game_settings.map_disaster_severity += INCREASE_AMOUNT


func _on_deactivate():
	print("B")
	game_manager.game_settings.map_disaster_severity -= INCREASE_AMOUNT
