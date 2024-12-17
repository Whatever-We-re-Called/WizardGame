extends VBoxContainer

signal readied

var player: Player


func setup(player: Player):
	self.player = player
	
	_update_current_spells_ui()


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


func _on_ready_button_pressed() -> void:
	readied.emit()
