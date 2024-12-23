class_name PerkPool extends Resource

@export var perks: Array[Perk]
@export_group("Debug")
@export var force_equal_weights: bool = false

func get_random_perks(quantity: int, allow_repeat_characters: bool) -> Array[Perk]:
	# TODO Actually account for weights properly and repeat characters
	# allowance check. Currently, this is purely temporary; I'd rather
	# focus on Perk functionality and visuals right now lol
	var result: Array[Perk]
	
	for i in range(quantity):
		result.append(perks[randi_range(0, perks.size() - 1)])
	
	return result
