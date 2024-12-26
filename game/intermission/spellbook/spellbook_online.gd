extends CenterContainer

var other_player_ui_nodes: Dictionary


func setup(player_data: Dictionary):
	%PlayerNameLabel.text = player_data["name"]


func _unload_current_page():
	for child in %PageContainer.get_children():
		child.queue_free()


func load_perk_page(perks: Array[Perk], perk_chosen_callable: Callable):
	_unload_current_page()
	
	var perk_page = preload("res://game/intermission/spellbook/ui_pages/perk_page.tscn").instantiate()
	perk_page.setup(perks)
	perk_page.perk_chosen.connect(perk_chosen_callable)
	%PageContainer.add_child(perk_page)


func load_spell_page(spell_types: Array[Spells.Type], spell_chosen_callable: Callable):
	_unload_current_page()
	
	var spell_page = preload("res://game/intermission/spellbook/ui_pages/spell_page.tscn").instantiate()
	spell_page.setup(spell_types)
	spell_page.spell_chosen.connect(spell_chosen_callable)
	%PageContainer.add_child(spell_page)


func load_inventory_page(player: Player, readied_callable: Callable):
	_unload_current_page()
	
	var inventory_page = preload("res://game/intermission/spellbook/ui_pages/inventory_page.tscn").instantiate()
	inventory_page.setup(player)
	inventory_page.readied.connect(readied_callable)
	%PageContainer.add_child(inventory_page)


func load_ready_page(unreadied_callable: Callable):
	_unload_current_page()
	
	var ready_page = preload("res://game/intermission/spellbook/ui_pages/ready_page.tscn").instantiate()
	ready_page.unreadied.connect(unreadied_callable)
	%PageContainer.add_child(ready_page)


@rpc("authority", "call_local", "reliable")
func create_other_players_page_progress_ui(other_players_data: Dictionary):
	for other_player_peer_id in other_players_data:
		var other_player_name = other_players_data[other_player_peer_id]["name"]
		
		var other_player_page_progress = preload("res://game/intermission/spellbook/online/other_player_page_progress_ui.tscn").instantiate()
		other_player_page_progress.setup(other_player_name)
		%OtherPlayerPageProgressContainer.add_child(other_player_page_progress)
		
		other_player_ui_nodes[other_player_peer_id] = other_player_page_progress


func update_page_progress_ui(current_page: int, max_page: int):
	%PageProgressBar.min_value = 0
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


#@rpc("any_peer", "call_local", "reliable")
#func _update_other_player_page_progress_ui(other_player_peer_id: int, current_page: int, max_page: int):
	#for other_player_data in other_players_data:
		#var peer_id = other_players_data[other_player_data]["peer_id"]
		#if peer_id == other_player_peer_id:
			#var ui_node = other_players_data[other_player_data]["ui_node"]
			#ui_node.update(current_page, max_page)
