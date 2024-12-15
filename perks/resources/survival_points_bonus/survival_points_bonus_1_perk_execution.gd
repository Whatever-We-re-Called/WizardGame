extends PerkExecution

const BONUS_VALUE: int = 1


func _on_activate():
	game_manager.game_scoring.add_survival_bonus(executor_player, BONUS_VALUE)


func _on_deactivate():
	game_manager.game_scoring.remove_survival_bonus(executor_player, BONUS_VALUE)
