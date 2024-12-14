extends GameManagerModule

var distance_perk_pools: Array = [
	preload("res://perks/pools/distance_1_perk_pool.tres"),
	preload("res://perks/pools/distance_2_perk_pool.tres"),
	preload("res://perks/pools/distance_3_perk_pool.tres"),
	preload("res://perks/pools/distance_4_perk_pool.tres"),
	preload("res://perks/pools/distance_5_perk_pool.tres")
]


func get_perks_from_pool(player: Player, perk_count: int):
	var distance = _get_distance_from_leading_player(player)
	var perk_pool = _get_distance_perk_pool(distance)
	
	return perk_pool.get_random_perks(perk_count, false)


func _get_distance_from_leading_player(player: Player) -> int:
	var leading_players = game_manager.game_scoring.get_leading_players()
	if leading_players.size() == 0: return 0
	
	var leading_player_score = game_manager.game_scoring.get_player_score(leading_players[0])
	var player_score = game_manager.game_scoring.get_player_score(player)
	return leading_player_score - player_score


func _get_distance_perk_pool(distance: int) -> PerkPool:
	var result: PerkPool
	
	for distance_perk_pool in distance_perk_pools:
		if distance < distance_perk_pool.max_distance:
			result = distance_perk_pool
	
	if result == null:
		result = distance_perk_pools[distance_perk_pools.size() - 1]
	
	return result
