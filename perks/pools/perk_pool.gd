class_name PerkPool extends Resource

@export var group_minimum_distances: Array[int]
@export var perks: Array[PerkPoolEntry]
@export_group("Debug")
@export var force_equal_weights: bool = false
@export var force_unique_characters: bool = false


func get_weighted_random_perks(quantity: int, group: int, allow_repeat_characters: bool) -> Array[Perk]:
	var result: Array[Perk]
	
	var perk_entry_weights = _get_perk_entry_weights(group)
	for i in range(quantity):
		var total_weight = 0
		var cumulative_weights = []
		for perk_entry in perk_entry_weights:
			var weight = perk_entry_weights[perk_entry]
			total_weight += weight
			cumulative_weights.append(total_weight)
		
		var random_value = randi_range(0, total_weight - 1)
		
		for j in range(cumulative_weights.size()):
			var perk_entry = perk_entry_weights.keys()[j]
			if random_value < cumulative_weights[j]:
				result.append(perk_entry.perk)
				perk_entry_weights.erase(perk_entry)
				if allow_repeat_characters == false:
					perk_entry_weights = _remove_character_from_perk_entry_weights(perk_entry_weights, perk_entry.perk.character)
				
				break
	
	return result


func _get_perk_entry_weights(group: int) -> Dictionary:
	var perk_entry_weights: Dictionary
	for perk in perks:
		if group > perk.group_weights.size(): continue
		
		var weight = perk.group_weights[group - 1]
		if weight > 0:
			perk_entry_weights[perk] = weight
	
	return perk_entry_weights


func _remove_character_from_perk_entry_weights(perk_entry_weights: Dictionary, character: PerkCharacter) -> Dictionary:
	var perk_entry_weights_copy = perk_entry_weights.duplicate()
	for perk_entry in perk_entry_weights_copy:
		if perk_entry.perk.character == character:
			perk_entry_weights.erase(perk_entry)
	
	return perk_entry_weights


func get_completely_random_perks(quantity: int, allow_repeat_characters: bool) -> Array[Perk]:
	var result: Array[Perk]
	
	while result.size() < quantity:
		var possible_perk = perks[randi_range(0, perks.size() - 1)]
		
		var same_found = false
		if force_unique_characters == true:
			for result_perk in result:
				if possible_perk.character == result_perk.character:
					same_found = true
		if same_found == true: continue
		
		result.append(possible_perk)
	
	return result
