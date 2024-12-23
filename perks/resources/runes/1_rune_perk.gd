extends PerkExecution


func _on_activate():
	executor_player.spell_inventory.add_runes(1)
