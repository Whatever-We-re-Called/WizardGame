class_name Spellbook

enum PageType { PERK, SPELL, INVENTORY, READY }

var open_page: SpellbookPage
var head_page: SpellbookPage
var tail_page: SpellbookPage


func next_page():
	if open_page.next_page != null:
		open_page = open_page.next_page


func previous_page():
	if open_page.previous_page != null:
		open_page = open_page.previous_page


func get_open_page_number() -> int:
	var result = 1
	
	var current_page = head_page
	while current_page != null:
		if current_page == open_page:
			break
		else:
			result += 1
			current_page = current_page.next_page
	
	return result


func size() -> int:
	var result = 1
	
	var current_page = head_page
	while current_page != null:
		if current_page.next_page == null:
			break
		else:
			result += 1
			current_page = current_page.next_page
	
	return result


func _append_page(new_page: SpellbookPage, page_type: PageType):
	if head_page == null:
		head_page = new_page
		tail_page = new_page
		return
	
	var current_page = head_page
	while current_page != null:
		if current_page.TYPE > page_type:
			break
		current_page = current_page.next_page
	
	if current_page == null:
		tail_page.next_page = new_page
		new_page.previous_page = tail_page
		tail_page = new_page
	elif current_page == head_page:
		new_page.next_page = head_page
		head_page.previous_page = new_page
		head_page = new_page
	else:
		new_page.previous_page = current_page.previous_page
		new_page.next_page = current_page
		current_page.previous_page.next_page = new_page
		current_page.previous_page = new_page


func append_perk_page(perks: Array[Perk], perk_chosen_callable: Callable):
	var perk_page = preload("res://game/intermission/modifying/ui_pages/perk_page.tscn").instantiate()
	perk_page.setup(perks)
	perk_page.perk_chosen.connect(perk_chosen_callable)
	_append_page(perk_page, PageType.PERK)


func append_spell_page(spell_types: Array[Spells.Type], spell_chosen_callable: Callable, skipped_callable: Callable):
	var spell_page = preload("res://game/intermission/modifying/ui_pages/spell_page.tscn").instantiate()
	spell_page.setup(spell_types)
	spell_page.spell_chosen.connect(spell_chosen_callable)
	spell_page.skipped.connect(skipped_callable)
	_append_page(spell_page, PageType.SPELL)


func append_inventory_page(player: Player, readied_callable: Callable):
	var inventory_page = preload("res://game/intermission/modifying/ui_pages/inventory_page.tscn").instantiate()
	inventory_page.setup(player)
	inventory_page.readied.connect(readied_callable)
	_append_page(inventory_page, PageType.INVENTORY)


func append_ready_page(unreadied_callable: Callable):
	var ready_page = preload("res://game/intermission/modifying/ui_pages/ready_page.tscn").instantiate()
	ready_page.unreadied.connect(unreadied_callable)
	_append_page(ready_page, PageType.READY)


func update_inventory_page():
	var inventory_page = head_page
	while inventory_page != null:
		if inventory_page.TYPE == PageType.INVENTORY:
			break
		else:
			inventory_page = inventory_page.next_page
	
	inventory_page.update_from_external_source_change()
