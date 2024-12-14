extends GameManagerModule

var player_perk_choice_counts: Dictionary

const DISTANCE_PERK_POOLS: Array = [
	preload("res://perks/pools/distance_1_perk_pool.tres"),
	preload("res://perks/pools/distance_2_perk_pool.tres"),
	preload("res://perks/pools/distance_3_perk_pool.tres"),
	preload("res://perks/pools/distance_4_perk_pool.tres"),
	preload("res://perks/pools/distance_5_perk_pool.tres")
]


func get_player_perk_choice_count(player: Player) -> int:
	if not player_perk_choice_counts.has(player):
		_reset_player_perk_choice_count(player)
	
	return player_perk_choice_counts[player]


func increment_player_perk_choice_count(player: Player, increment: int):
	if not player_perk_choice_counts.has(player):
		_reset_player_perk_choice_count(player)
	
	player_perk_choice_counts[player] += increment


func reset_player_perk_choice_counts():
	player_perk_choice_counts.clear()
	for player in game_manager.players:
		_reset_player_perk_choice_count(player)


func _reset_player_perk_choice_count(player: Player):
	player_perk_choice_counts[player] = game_manager.game_settings.default_perk_choice_count


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
	for distance_perk_pool in DISTANCE_PERK_POOLS:
		print("1")
		if distance < distance_perk_pool.max_distance:
			return distance_perk_pool
	
	return DISTANCE_PERK_POOLS[DISTANCE_PERK_POOLS.size() - 1]
