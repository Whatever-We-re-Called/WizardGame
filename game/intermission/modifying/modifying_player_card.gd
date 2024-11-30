extends CenterContainer

var current_page: int
var pages: Array[VBoxContainer]


func setup(perk_pages_dictionary: Dictionary, player_scene_path: String):
	for page_dictionary in perk_pages_dictionary:
		var perks: Array[Perk]
		for ability_resource_path in perk_pages_dictionary[page_dictionary]:
			perks.append(load(ability_resource_path))
		
		_append_perks_page(perks)
	
	var player = get_tree().root.get_node_or_null(player_scene_path)
	_append_abilities_page(player)
	
	_append_ready_page()
	
	%PageProgressBar.min_value = 0
	%PageProgressBar.max_value = pages.size() - 1
	
	self.current_page = 1
	_update_page()


func _append_perks_page(perks: Array[Perk]):
	var perks_page = preload("res://game/intermission/modifying/ui_pages/perks_page.tscn").instantiate()
	perks_page.setup(perks)
	perks_page.perk_chosen.connect(
		func(perk_resource_path: String):
			# TODO Send chosen perk info to Perk GameModule.
			_next_page()
	)
	pages.append(perks_page)


func _append_abilities_page(player: Player):
	var abilities_page = preload("res://game/intermission/modifying/ui_pages/abilities_page.tscn").instantiate()
	abilities_page.setup(player)
	abilities_page.readied.connect(
		# TODO Update player ability inventory data.
		func(): _next_page()
	)
	pages.append(abilities_page)


func _append_ready_page():
	var ready_page = preload("res://game/intermission/modifying/ui_pages/ready_page.tscn").instantiate()
	ready_page.unreadied.connect(
		func(): _previous_page()
	)
	pages.append(ready_page)


func _next_page():
	current_page += 1
	_update_page()


func _previous_page():
	current_page -= 1
	_update_page()


func _update_page():
	for child in %PageContainer.get_children():
		%PageContainer.remove_child(child)
	
	var page = pages[current_page - 1]
	%PageContainer.add_child(page)
	
	_update_page_progress_bar_ui()


func _update_page_progress_bar_ui():
	%PageProgressBar.value = current_page - 1
	
	if current_page == pages.size():
		var ready_fill_style = StyleBoxFlat.new()
		ready_fill_style.bg_color = Color.GREEN
		%PageProgressBar.add_theme_stylebox_override("fill", ready_fill_style)
	else:
		var in_progress_fill_style = StyleBoxFlat.new()
		in_progress_fill_style.bg_color = Color.WHITE
		%PageProgressBar.add_theme_stylebox_override("fill", in_progress_fill_style)
