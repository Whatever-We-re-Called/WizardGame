extends PerkExecution


func _on_activate():
	executor_player.spell_inventory.add_extra_spell_page_count(1)
