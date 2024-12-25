extends CenterContainer

signal page_updated(current_page: int, max_page: int)
signal perk_obtained(perk_resource_path: String)
signal spell_obtained(spell_type: Spells.Type)

var current_page: int
var pages: Array[VBoxContainer]
var inventory_page: VBoxContainer


func setup_online(player_data: Dictionary):
	%PlayerNameLabel.text = player_data["name"]
	
	var perk_pages = player_data["perk_pages"]
	for perk_page in perk_pages:
		var perks: Array[Perk]
		for ability_resource_path in perk_pages[perk_page]:
			perks.append(load(ability_resource_path))
		
		_append_perks_page(perks)
	
	# TODO Make this dynamic
	var spell_pages = player_data["spell_pages"]
	for spell_page in spell_pages:
		var spell_types: Array[Spells.Type]
		for spell_type in spell_pages[spell_page]:
			spell_types.append(spell_type)
		
		_append_spell_page(spell_types)
	
	var player = get_tree().root.get_node_or_null(player_data["node_path"])
	_append_inventory_page(player)
	
	_append_ready_page()
	
	%PageProgressBar.min_value = 0
	%PageProgressBar.max_value = pages.size() - 1
	
	self.current_page = 1
	_update_page()


func _append_perks_page(perks: Array[Perk]):
	var perk_page = preload("res://game/intermission/modifying/ui_pages/perk_page.tscn").instantiate()
	perk_page.setup(perks)
	perk_page.perk_chosen.connect(
		func(perk_resource_path: String):
			perk_obtained.emit(perk_resource_path)
			inventory_page.update_from_external_source_change()
			_next_page()
	)
	pages.append(perk_page)


func _append_spell_page(spell_types):
	var spell_page = preload("res://game/intermission/modifying/ui_pages/spell_page.tscn").instantiate()
	spell_page.setup(spell_types)
	spell_page.spell_chosen.connect(
		func(spell_type: Spells.Type):
			spell_obtained.emit(spell_type)
			inventory_page.update_from_external_source_change()
			_next_page()
	)
	spell_page.skipped.connect(
		func(spell_type: Spells.Type):
			_next_page()
	)
	pages.append(spell_page)


func _append_inventory_page(player: Player):
	var inventory_page = preload("res://game/intermission/modifying/ui_pages/inventory_page.tscn").instantiate()
	inventory_page.setup(player)
	inventory_page.readied.connect(
		# TODO Update player ability inventory data.
		# Currently it is being done in the page's code itself.
		# Maybe this is fine? Maybe it needs to be changed? idk, TODO
		func(): _next_page()
	)
	pages.append(inventory_page)
	self.inventory_page = inventory_page


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
	
	page_updated.emit(current_page, pages.size())
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
