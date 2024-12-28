extends VBoxContainer


func populate(warning_text: String, executor_player_name: String):
	%WarningText.text = warning_text
	%ExecutorPlayerLabel.text = "%s, %s" % [_get_random_signoff(), executor_player_name]


func _get_random_signoff() -> String:
	var options = [
		"From",
		"Sincerely",
		"Yours truly",
		"Peace",
		"Fuck you",
		"Gotta blast",
		"Good luck",
		"See you in hell",
		"Hugs and kisses",
		"Stay classy",
	]
	return options[randi_range(0, options.size() - 1)]
