extends CenterContainer

@onready var scores_list: GridContainer = %ScoresList


@rpc("authority", "call_local", "reliable")
func update(players: Array[Player], scores: Dictionary):
	for child in scores_list.get_children():
		child.queue_free()
	
	var label_settings = LabelSettings.new()
	label_settings.font_size = 24
	
	for player in players:
		var score = 0
		if scores.has(player):
			score = scores[player]
		
		var player_name_label = Label.new()
		player_name_label.text = player.name + ":"
		player_name_label.label_settings = label_settings
		scores_list.add_child(player_name_label)
		
		var player_score_label = Label.new()
		player_score_label.text = str(score)
		player_score_label.label_settings = label_settings
		scores_list.add_child(player_score_label)
