class_name PerkPool extends Resource

@export var max_distance: int = 0
@export var perks: Array[Perk]
@export_group("Rarity Weights")
@export var common_rarity_weight: int = 0
@export var uncommon_rarity_weight: int = 0
@export var rare_rarity_weight: int = 0

var rarity_weights: Dictionary:
	get:
		var result: Dictionary
		result[Perk.Rarity.COMMON] = common_rarity_weight
		result[Perk.Rarity.UNCOMMON] = uncommon_rarity_weight
		result[Perk.Rarity.RARE] = rare_rarity_weight
		return result
var rarity_weights_total: int:
	get:
		return common_rarity_weight\
			+ uncommon_rarity_weight\
			+ rare_rarity_weight


func get_random_perks(quantity: int, allow_duplicates: bool) -> Array[Perk]:
	var result: Array[Perk]
	
	var perks_pool_copy = perks.duplicate()
	randomize()
	for i in range(quantity):
		var chosen_perk = _get_random_perk_with_weights(perks_pool_copy)
		result.append(chosen_perk)
		
		if allow_duplicates == false and perks_pool_copy.size() >= quantity:
			perks_pool_copy.erase(chosen_perk)
	
	return result


# Made this its own function to allow it to recursively call itself.
func _get_random_perk_with_weights(perks_pool: Array[Perk], attempts: int = 0) -> Perk:
	if attempts > 100: return perks_pool[0]
	
	var random_weight: int = randi_range(1, rarity_weights_total)
	var cumulative_weight = 0
	for rarity in rarity_weights:
		cumulative_weight += rarity_weights[rarity]
		if random_weight <= cumulative_weight:
			var perks_of_rarity = _get_perks_of_rarity(perks_pool, rarity)
			
			if perks_of_rarity.size() > 0:
				return perks_of_rarity[randi_range(0, perks_of_rarity.size() - 1)]
			else:
				return _get_random_perk_with_weights(perks_pool, attempts + 1)
	
	# Algorithm failed (somehow).
	return perks_pool[0]


func _get_perks_of_rarity(perks_pool: Array[Perk], rarity: Perk.Rarity) -> Array[Perk]:
	var result: Array[Perk]
	
	for perk in perks_pool:
		if rarity == perk.rarity:
			result.append(perk)
	
	return result
