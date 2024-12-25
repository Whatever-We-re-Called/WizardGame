class_name SpellPool extends Resource

@export var spell_types: Array[Spells.Type]


func get_random_spells(quantity: int) -> Array[Spells.Type]:
	return get_lacking_random_spells(quantity, null)


func get_lacking_random_spells(quantity: int, player: Player) -> Array[Spells.Type]:
	var result: Array[Spells.Type]
	
	var spell_types_copy = spell_types.duplicate()
	
	if player != null:
		for spell_type in player.spell_inventory.levels:
			spell_types_copy.erase(spell_type)
	
	randomize()
	spell_types_copy.shuffle()
	for i in range(quantity):
		if i >= spell_types_copy.size() - 1:
			break
		else:
			result.append(spell_types_copy[i])
	
	return result
