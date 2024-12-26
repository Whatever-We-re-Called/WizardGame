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
