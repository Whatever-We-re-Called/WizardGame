extends PerkExecution


func _on_activate():
	pass
	executor_player.spell_inventory.set_all_level_override(1)


func _on_deactivate():
	executor_player.spell_inventory.clear_all_level_override()
	executor_player.spell_inventory.add_all_level_bonus(1)
