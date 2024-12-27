extends PerkExecution

var affected_players: Array[Player]


func _on_activate():
	affected_players = game_manager.game_scoring.get_leading_players()
	for player in affected_players:
		player.spell_inventory.remove_all_level_bonus(1)


func _on_deactivate():
	for player in affected_players:
		player.spell_inventory.add_all_level_bonus(1)
	affected_players.clear()
