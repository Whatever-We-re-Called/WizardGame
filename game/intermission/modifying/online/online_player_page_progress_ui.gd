extends MarginContainer


func setup(player_name: String):
	%PlayerNameLabel.text = player_name
	
	%PageProgressBar.min_value = 0


func update(current_page: int, max_page: int):
	%PageProgressBar.value = current_page - 1
	%PageProgressBar.max_value = max_page - 1
