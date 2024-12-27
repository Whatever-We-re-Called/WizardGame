extends PerkExecution


func _on_activate():
	executor_player.spell_inventory.add_temporary_level_bonus(1)


func _on_deactivate():
	executor_player.spell_inventory.remove_temporary_level_bonus(1)
