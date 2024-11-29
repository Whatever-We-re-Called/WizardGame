extends CenterContainer

var current_page: int
var pages: Array[VBoxContainer]


func setup(perk_pages_dictionary: Dictionary):
	for page_dictionary in perk_pages_dictionary:
		var perks: Array[Perk]
		
		var ability_resource_paths = perk_pages_dictionary[page_dictionary]
		for ability_resource_path in ability_resource_paths:
			perks.append(load(ability_resource_path))
		
		_append_perks_page(perks)
	
	self.current_page = 1
	_update_page()


func _append_perks_page(perks: Array[Perk]):
	var perks_page = preload("res://game/intermission/modifying/ui_pages/perks_page.tscn").instantiate()
	perks_page.setup(perks)
	pages.append(perks_page)


func _update_page():
	for child in %PageContainer.get_children():
		child.queue_free()
	
	var page = pages[current_page - 1]
	%PageContainer.add_child(page)


func _create_abilities_page():
	pass
