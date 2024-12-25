extends CenterContainer

signal page_updated(current_page: int, max_page: int)
signal perk_obtained(perk_resource_path: String)
signal spell_obtained(spell_type: Spells.Type)

var spellbook: Spellbook


func setup(player_data: Dictionary):
	%PlayerNameLabel.text = player_data["name"]
	
	spellbook = Spellbook.new()


func create_perk_page(perk_resource_paths: Array[String]):
	var perks: Array[Perk]
	for perk_resource_path in perk_resource_paths:
		perks.append(load(perk_resource_path))
	
	spellbook.append_perk_page(
		perks, 
		func(perk_resource_path: String):
			perk_obtained.emit(perk_resource_path)
			_handle_perk_page_finish()
			load_next_page()
	)


func _handle_perk_page_finish():
	spellbook.update_inventory_page()


func create_spell_page(generated_spell_types: Array[Spells.Type]):
	var spell_types: Array[Spells.Type]
	for spell_type in generated_spell_types:
		spell_types.append(spell_type)
	
	spellbook.append_spell_page(
		spell_types, 
		func(spell_type: Spells.Type):
			spell_obtained.emit(spell_type)
			spellbook.update_inventory_page()
			load_next_page(),
		func():
			load_next_page()
	)


func load_first_page():
	spellbook.open_page = spellbook.head_page
	print(spellbook.open_page)
	_load_open_page()


func load_next_page():
	spellbook.next_page()
	_load_open_page()


func load_previous_page():
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
