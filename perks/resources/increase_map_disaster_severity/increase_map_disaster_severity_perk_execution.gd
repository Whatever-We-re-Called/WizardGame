extends PerkExecution

const INCREASE_AMOUNT: int = 5


func _on_activate():
	game_manager.game_settings.map_disaster_severity += INCREASE_AMOUNT


func _on_deactivate():
	game_manager.game_settings.map_disaster_severity -= INCREASE_AMOUNT
