class_name PerkPool extends Resource

@export var max_distance: int = 0
@export var perks: Array[Perk]
@export_group("Rarity Chances")
@export_range(0.0, 1.0) var common_rarity_chance: float = 0.0
@export_range(0.0, 1.0) var uncommon_rarity_chance: float = 0.0
@export_range(0.0, 1.0) var rare_rarity_chance: float = 0.0


func get_random_perks(quantity: int, allow_duplicates: bool) -> Array[Perk]:
	var result: Array[Perk]
	
	var perks_copy = perks.duplicate()
	randomize()
	for i in range(quantity):
		var random_index = randi_range(0, perks_copy.size() - 1)
		result.append(perks_copy[random_index])
		
		if allow_duplicates == false and perks_copy.size() >= quantity:
			perks_copy.remove_at(random_index)
	
	return result
