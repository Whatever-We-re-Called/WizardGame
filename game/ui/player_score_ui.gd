extends CenterContainer

@onready var scores_list: GridContainer = %ScoresList


func update(players: Array[Player], scores: Dictionary):
	_clear_all_labels.rpc()
	
	for player in players:
		var score = 0
		if scores.has(player):
			score = scores[player]
		
		_create_score_label.rpc(player.peer_id, score)


@rpc("authority", "call_local", "reliable")
func _clear_all_labels():
	for child in scores_list.get_children():
		child.queue_free()


@rpc("authority", "call_local", "reliable")
func _create_score_label(peer_id: int, score: int):
	var label_settings = LabelSettings.new()
	label_settings.font_size = 24
	
	var player_name_label = Label.new()
	player_name_label.text = str(peer_id) + ":"
	player_name_label.label_settings = label_settings
	scores_list.add_child(player_name_label)
	
	var player_score_label = Label.new()
	player_score_label.text = str(score)
	player_score_label.label_settings = label_settings
	scores_list.add_child(player_score_label)
