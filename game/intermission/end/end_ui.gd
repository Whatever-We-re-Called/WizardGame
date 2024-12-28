extends IntermissionUI


func generate_perk_warnings():
	if intermission.player_perk_executions.size() > 0:
		%PerkWarningsContainer.visible = true
		for player in intermission.player_perk_executions:
			for perk in intermission.player_perk_executions[player]:
				if perk.has_warning == true:
					_create_perk_warning_ui.rpc(perk.warning, player.get_display_name())
	else:
		%PerkWarningsContainer.visible = false


@rpc("authority", "call_local", "reliable")
func _create_perk_warning_ui(warning_text: String, executor_player_name: String):
	var perk_warning = preload("res://perks/ui/perk_warning.tscn").instantiate()
	%PerkWarningsGrid.add_child(perk_warning)
	perk_warning.populate(warning_text, executor_player_name)
