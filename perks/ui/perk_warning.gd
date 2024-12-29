extends VBoxContainer


func populate(warning_text: String, executor_player_name: String, funny_signoff: String):
	%WarningText.text = warning_text
	%ExecutorPlayerLabel.text = "%s, %s" % [funny_signoff, executor_player_name]
