class_name InventoryPage extends SpellbookPage

signal readied

var player: Player
var item_spell_types: Array[Spells.Type]

const TYPE: Spellbook.PageType = Spellbook.PageType.INVENTORY


func setup(player: Player):
	self.player = player
	
	_update_current_spells_ui()
	_populate_spell_list()
	_update_select_spell_slot_buttons()
	_update_spell_upgrade_button()


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
	
	%CurrentRunesLabel.text = "Runes: %s" % [player.spell_inventory.runes]


func _populate_spell_list():
	%SpellsList.clear()
	item_spell_types.clear()
	
	%SpellsList.add_item("None")
	item_spell_types.append(Spells.Type.NONE)
	for spell_type in Spells.Type.values():
		if player.spell_inventory.has(spell_type):
			var spell_resource = Spells.get_spell_resource(spell_type)
			var spell_icon = spell_resource.icon_texture
			var spell_name = spell_resource.name
			var spell_level = player.spell_inventory.get_true_level(spell_type)
			var max_spell_level = spell_resource.max_level
			
			var text = "%s (Level: %s/%s)" % [spell_name, spell_level, max_spell_level]
			%SpellsList.add_item(text, spell_icon, true)
			
			item_spell_types.append(spell_type)


func _on_spells_list_item_selected(index: int) -> void:
	var selected_spell = item_spell_types[index]
	var spell_resource = Spells.get_spell_resource(selected_spell)
	var spell_level = player.spell_inventory.get_level(selected_spell)
	_set_spell_description(spell_resource, spell_level)
	
	_update_select_spell_slot_buttons()
	_update_spell_upgrade_button()


func _set_spell_description(spell_resource: Spell, spell_level: int):
	%SpellDescriptionContainer.visibility_layer = 1
	
	%SpellNameLabel.text = spell_resource.name
	
	var max_spell_level = spell_resource.max_level
	%SpellLevelLabel.text = "%s/%s" % [spell_level, max_spell_level]
	
	%SpellDescriptionLabel.text = spell_resource.description


func _clear_spell_description():
	%SpellDescriptionContainer.visibility_layer = 0


func _on_select_spell_button_pressed(spell_slot: int) -> void:
	var selected_spell = _get_list_selected_spell()
	_select_new_equipped_spell(spell_slot, selected_spell)


func _select_new_equipped_spell(spell_slot: int, selected_spell: Spells.Type):
	for i in range(player.spell_inventory.equipped_spell_types.size()):
		var checked_spell = player.spell_inventory.equipped_spell_types[i]
		if selected_spell == checked_spell:
			player.spell_inventory.set_spell_slot.rpc_id(player.peer_id, i, Spells.Type.NONE)
	
	player.spell_inventory.set_spell_slot.rpc(spell_slot - 1, selected_spell)
	_update_current_spells_ui()
	_update_select_spell_slot_buttons()
	_update_spell_upgrade_button()


func _update_select_spell_slot_buttons():
	var select_spell_slot_buttons = [
		%SelectSpellSlot1Button, %SelectSpellSlot2Button, %SelectSpellSlot3Button
	]
	
	for i in range(player.spell_inventory.equipped_spell_types.size()):
		var select_spell_slot_button = select_spell_slot_buttons[i]
		if %SpellsList.get_selected_items().size() > 0:
			var equipped_spell_type = player.spell_inventory.equipped_spell_types[i]
			var selected_spell_type = _get_list_selected_spell()
			select_spell_slot_button.disabled = equipped_spell_type == selected_spell_type
		else:
			select_spell_slot_button.disabled = true


func _get_list_selected_spell() -> Spells.Type:
	if %SpellsList.get_selected_items().size() == 0: return Spells.Type.NONE
	
	for spell_type in Spells.Type.values():
		var item_spell_types_index = item_spell_types.find(spell_type, 0)
		if item_spell_types_index == -1: 
			continue
		elif %SpellsList.is_selected(item_spell_types_index) == true:
			return spell_type
	
	return Spells.Type.NONE


func _update_spell_upgrade_button():
	if %SpellsList.get_selected_items().size() == 0:
		%UpgradeSpellButton.disabled = true
		%UpgradeSpellButton.text = "Upgrade: N/A"
	else:
		var selected_spell_type = _get_list_selected_spell()
		if player.spell_inventory.is_spell_max_level(selected_spell_type):
			%UpgradeSpellButton.disabled = true
			%UpgradeSpellButton.text = "Upgrade: Max"
		else:
			var upgrade_cost = player.spell_inventory.get_upgrade_cost(selected_spell_type)
			%UpgradeSpellButton.disabled = player.spell_inventory.runes < upgrade_cost
			%UpgradeSpellButton.text = "Upgrade: %s Rune(s)" % [upgrade_cost]


func _on_upgrade_spell_button_pressed() -> void:
	if %SpellsList.get_selected_items().size() == 1:
		var selected_spell_type = _get_list_selected_spell()
		player.spell_inventory.upgrade_spell(selected_spell_type)
	
		_update_current_spells_ui()
		_populate_spell_list()
		for i in range(item_spell_types.size()):
			var item_spell_type = item_spell_types[i]
			if selected_spell_type == item_spell_type:
				%SpellsList.select(i, true)
		_update_select_spell_slot_buttons()
		_update_spell_upgrade_button()


func _on_ready_button_pressed() -> void:
	readied.emit()


func update_from_external_source_change():
	_update_current_spells_ui()
	_populate_spell_list()
	_update_select_spell_slot_buttons()
	_update_spell_upgrade_button()
