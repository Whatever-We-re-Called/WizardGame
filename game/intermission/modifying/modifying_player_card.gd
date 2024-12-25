extends CenterContainer

signal page_updated(current_page: int, max_page: int)
signal perk_obtained(perk_resource_path: String)
signal spell_obtained(spell_type: Spells.Type)

var spellbook: Spellbook


func setup_online(player_data: Dictionary):
	%PlayerNameLabel.text = player_data["name"]
	
	spellbook = Spellbook.new()
	
	var perk_pages = player_data["perk_pages"]
	for perk_page in perk_pages:
		var perks: Array[Perk]
		for ability_resource_path in perk_pages[perk_page]:
			perks.append(load(ability_resource_path))
		
		spellbook.append_perk_page(
			perks, 
			func(perk_resource_path: String):
				perk_obtained.emit(perk_resource_path)
				_load_next_page()
		)
	
	var spell_pages = player_data["spell_pages"]
	for spell_page in spell_pages:
		var spell_types: Array[Spells.Type]
		for spell_type in spell_pages[spell_page]:
			spell_types.append(spell_type)
		
		spellbook.append_spell_page(
			spell_types, 
			func(spell_type: Spells.Type):
				spell_obtained.emit(spell_type)
				_load_next_page(),
			func():
				_load_next_page()
		)
	
	var player = get_tree().root.get_node_or_null(player_data["node_path"])
	spellbook.append_inventory_page(
		player,
		func():
			_load_next_page()
	)
	
	spellbook.append_ready_page(
		func():
			_load_previous_page()
	)
	
	_load_first_page()


func _load_first_page():
	spellbook.open_page = spellbook.head_page
	print(spellbook.open_page)
	_load_open_page()


func _load_next_page():
	spellbook.next_page()
	_load_open_page()


func _load_previous_page():
	spellbook.previous_page()
	_load_open_page()


func _load_open_page():
	for child in %PageContainer.get_children():
		%PageContainer.remove_child(child)
	
	%PageContainer.add_child(spellbook.open_page)
	
	page_updated.emit(spellbook.get_open_page_number(), spellbook.size())
	_update_page_progress_bar_ui()


func _update_page_progress_bar_ui():
	%PageProgressBar.min_value = 0
	%PageProgressBar.max_value = spellbook.size() - 1
	%PageProgressBar.value = spellbook.get_open_page_number() - 1
	
	if spellbook.get_open_page_number() == spellbook.size():
		var ready_fill_style = StyleBoxFlat.new()
		ready_fill_style.bg_color = Color.GREEN
		%PageProgressBar.add_theme_stylebox_override("fill", ready_fill_style)
	else:
		var in_progress_fill_style = StyleBoxFlat.new()
		in_progress_fill_style.bg_color = Color.WHITE
		%PageProgressBar.add_theme_stylebox_override("fill", in_progress_fill_style)
