extends VBoxContainer

signal readied

var player: Player


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
	%SpellsList.clear()
	for equipped_spell_type in player.spell_inventory.equipped_spell_types:
		var spell_resource = Spells.get_spell_resource(equipped_spell_type)
		var spell_icon = spell_resource.icon_texture
		var spell_name = spell_resource.name
		var spell_level = player.spell_inventory.get_level(equipped_spell_type)
		var max_spell_level = spell_resource.max_level
		
		var text = "%s (Level: %s/%s)" % [spell_name, spell_level, max_spell_level]
		var is_selectable = player.spell_inventory.equipped_spells[spell_slot - 1].get_script() != Spells.get_spell_script(equipped_spell_type)
		%SpellsList.add_item(text, spell_icon, is_selectable)


func _on_ready_button_pressed() -> void:
	readied.emit()
