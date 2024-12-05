extends MarginContainer


func setup(player_name: String):
	%PlayerNameLabel.text = player_name
	
	%PageProgressBar.min_value = 0


func update(current_page: int, max_page: int):
	%PageProgressBar.value = current_page - 1
	%PageProgressBar.max_value = max_page - 1
	
	if current_page == max_page:
		var ready_fill_style = StyleBoxFlat.new()
		ready_fill_style.bg_color = Color.GREEN
		%PageProgressBar.add_theme_stylebox_override("fill", ready_fill_style)
	else:
		var in_progress_fill_style = StyleBoxFlat.new()
		in_progress_fill_style.bg_color = Color.WHITE
		%PageProgressBar.add_theme_stylebox_override("fill", in_progress_fill_style)
