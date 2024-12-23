extends PerkExecution


func _on_activate():
	game_manager.game_scoring.set_survival_bonus(executor_player, 1)


func _on_deactivate():
	game_manager.game_scoring.set_survival_bonus(executor_player, 0)
