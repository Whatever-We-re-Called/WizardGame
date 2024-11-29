class_name PerkPool extends Resource

@export var perks: Array[Perk]


func get_random_perks(quantity: int, allow_duplicates: bool) -> Array[Perk]:
	var result: Array[Perk]
	
	var perks_copy = perks.duplicate()
	randomize()
	for i in range(quantity):
		var random_index = randi_range(0, perks_copy.size() - 1)
		result.append(perks_copy[random_index])
		
		if allow_duplicates == false:
			perks_copy.remove_at(random_index)
	
	return result
