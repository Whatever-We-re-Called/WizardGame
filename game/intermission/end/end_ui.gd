extends IntermissionUI


func generate_perk_warnings():
	for player in intermission.player_perk_executions:
		for perk in intermission.player_perk_executions[player]:
			if perk.has_warning == true:
				_create_perk_warning_ui.rpc(perk.warning, player.get_display_name(), _get_random_signoff())


func _get_random_signoff() -> String:
	var options = [
		"From",
		"Sincerely",
		"Yours truly",
		"Fuck you",
		"Gotta blast",
		"Good luck",
		"See you in hell",
		"Hugs and kisses",
		"Stay classy",
	]
	return options[randi_range(0, options.size() - 1)]


@rpc("authority", "call_local", "reliable")
func _create_perk_warning_ui(warning_text: String, executor_player_name: String, funny_signoff: String):
	%PerkWarningsContainer.visible = true
	
	var perk_warning = preload("res://perks/ui/perk_warning.tscn").instantiate()
	%PerkWarningsGrid.add_child(perk_warning)
	perk_warning.populate(warning_text, executor_player_name, funny_signoff)
