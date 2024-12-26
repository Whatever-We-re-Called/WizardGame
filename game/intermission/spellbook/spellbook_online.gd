extends CenterContainer


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
