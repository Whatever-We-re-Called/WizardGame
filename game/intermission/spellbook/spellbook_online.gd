extends CenterContainer

signal perk_obtained(perk_resource_path: String)


func setup(player_data: Dictionary):
	%PlayerNameLabel.text = player_data["name"]


func _unload_current_page():
	for child in %PageContainer.get_children():
		child.queue_free()


func load_perk_page(perks: Array[Perk]):
	_unload_current_page()
	
	var perk_page = preload("res://game/intermission/spellbook/ui_pages/perk_page.tscn").instantiate()
	perk_page.setup(perks)
	perk_page.perk_chosen.connect(
		func(perk_resource_path: String):
			perk_obtained.emit(perk_resource_path)
	)
	%PageContainer.add_child(perk_page)
