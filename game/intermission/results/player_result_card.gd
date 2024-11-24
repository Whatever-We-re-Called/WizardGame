extends HBoxContainer


func setup(player_name: String, placement: int, player_score: int):
	%PlayerNameLabel.text = "%s. %s" % [str(placement), player_name]
	%PlayerNameLabel.label_settings.font_color = _get_placement_color(placement)
	
	%CurrentPointsLabel.text = str(player_score)


func _get_placement_color(placement: int) -> Color:
	match placement:
		1:
			return Color.GOLD
		2:
			return Color.SILVER
		3:
			return Color.SADDLE_BROWN
		_:
			return Color.WEB_GRAY
