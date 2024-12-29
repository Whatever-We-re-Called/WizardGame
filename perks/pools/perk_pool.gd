class_name PerkPool extends Resource

@export var perks: Array[PerkPoolEntry]
@export_group("Debug")
@export var force_equal_weights: bool = false
@export var force_unique_characters: bool = false

func get_random_perks(quantity: int, allow_repeat_characters: bool) -> Array[Perk]:
	# TODO Actually account for weights properly and repeat characters
	# allowance check. Currently, this is purely temporary; I'd rather
	# focus on Perk functionality and visuals right now lol
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
