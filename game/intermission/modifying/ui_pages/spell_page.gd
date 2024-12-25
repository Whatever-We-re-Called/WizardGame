extends SpellbookPage

signal spell_chosen(spell_type: Spells.Type)
signal skipped

var spell_types: Array[Spells.Type]

const TYPE: Spellbook.PageType = Spellbook.PageType.SPELL


func setup(spell_types: Array[Spells.Type]):
	if spell_types.size() == 0: skipped.emit()
	
	self.spell_types = spell_types
	
	_populate_spells_list()
	_update_select_button()


func _populate_spells_list():
	%SpellsList.clear()
	for spell_type in spell_types:
		var spell_resource = Spells.get_spell_resource(spell_type)
		var spell_icon = spell_resource.icon_texture
		var spell_name = spell_resource.name
		var max_spell_level = spell_resource.max_level
		
		%SpellsList.add_item(spell_name, spell_icon, true)


func _update_select_button():
	%SelectButton.disabled = %SpellsList.get_selected_items().size() == 0


func _on_spells_list_item_selected(index: int) -> void:
	var selected_spell = spell_types[index]
	var spell_resource = Spells.get_spell_resource(selected_spell)
	_set_spell_description(spell_resource)
	
	_update_select_button()


func _set_spell_description(spell_resource: Spell):
	%SpellNameLabel.text = spell_resource.name
	%SpellDescriptionLabel.text = spell_resource.description


func _get_list_selected_spell() -> Spells.Type:
	for spell_type in spell_types:
		var index = spell_types.find(spell_type, 0)
		if %SpellsList.is_selected(index) == true:
			return spell_type
	
	return Spells.Type.NONE


func _on_select_button_pressed() -> void:
	spell_chosen.emit(_get_list_selected_spell())
