extends VBoxContainer

signal readied

var player: Player
var item_list_spell_slot: int
var item_spell_types: Array[Spells.Type]


func setup(player: Player):
	self.player = player
	
	_update_current_spells_ui()
	_populate_spell_list(1)


func _update_current_spells_ui():
	var current_spell_icons = [
		%CurrentSpell1Icon, %CurrentSpell2Icon, %CurrentSpell3Icon 
	]
	var current_spell_level_labels = [
		%CurrentSpell1LevelLabel, %CurrentSpell2LevelLabel, %CurrentSpell3LevelLabel
	]
	
	for i in range(player.spell_inventory.equipped_spell_types.size()):
		var spell_type = player.spell_inventory.equipped_spell_types[i]
		var current_spell_icon = current_spell_icons[i]
		var current_spell_level_label = current_spell_level_labels[i]
		
		if spell_type != Spells.Type.NONE:
			var spell_resource = Spells.get_spell_resource(spell_type)
			current_spell_icon.texture = spell_resource.icon_texture
			
			var spell_level = player.spell_inventory.get_level(spell_type)
			var max_spell_level = spell_resource.max_level
			current_spell_level_label.text = "%s/%s" % [spell_level, max_spell_level]
		else:
			current_spell_icon.texture = null
			current_spell_level_label.text = "N/A"


func _populate_spell_list(spell_slot: int):
	item_list_spell_slot = spell_slot
	
	%SpellsList.clear()
	item_spell_types.clear()
	for spell_type in Spells.Type.values():
		if player.spell_inventory.has(spell_type):
			var spell_resource = Spells.get_spell_resource(spell_type)
			var spell_icon = spell_resource.icon_texture
			var spell_name = spell_resource.name
			var spell_level = player.spell_inventory.get_true_level(spell_type)
			var max_spell_level = spell_resource.max_level
			
			var text = "%s (Level: %s/%s)" % [spell_name, spell_level, max_spell_level]
			var is_selectable = true #not player.spell_inventory.equipped_spell_types.has(spell_type)
			%SpellsList.add_item(text, spell_icon, is_selectable)
			
			if spell_type == player.spell_inventory.equipped_spell_types[spell_slot - 1]:
				%SpellsList.select(%SpellsList.get_item_count() - 1)
			
			item_spell_types.append(spell_type)


func _on_spells_list_item_selected(index: int) -> void:
	var spell_slot = item_list_spell_slot
	var selected_spell = item_spell_types[index]
	_select_new_equipped_spell(spell_slot, selected_spell)
	
	var spell_resource = Spells.get_spell_resource(selected_spell)
	var spell_level = player.spell_inventory.get_level(selected_spell)
	_set_spell_description(spell_resource, spell_level)


func _select_new_equipped_spell(spell_slot: int, selected_spell: Spells.Type):
	for i in range(player.spell_inventory.equipped_spell_types.size()):
		var checked_spell = player.spell_inventory.equipped_spell_types[i]
		if selected_spell == checked_spell:
			player.spell_inventory.set_spell_slot.rpc(i, Spells.Type.NONE)
	
	player.spell_inventory.set_spell_slot.rpc(spell_slot - 1, selected_spell)
	_update_current_spells_ui()
	_populate_spell_list(spell_slot)


func _set_spell_description(spell_resource: Spell, spell_level: int):
	%SpellDescriptionContainer.visibility_layer = 1
	
	%SpellNameLabel.text = spell_resource.name
	
	var max_spell_level = spell_resource.max_level
	%SpellLevelLabel.text = "%s/%s" % [spell_level, max_spell_level]
	
	%SpellDescriptionLabel.text = spell_resource.description


func _clear_spell_description():
	%SpellDescriptionContainer.visibility_layer = 0


func _on_ready_button_pressed() -> void:
	readied.emit()
