extends PerkExecution

var affected_players: Array[Player]


func _on_activate():
	# TODO Player health is not currently implemented
	pass


func _on_deactivate():
	executor_player.spell_inventory.add_runes(4)
