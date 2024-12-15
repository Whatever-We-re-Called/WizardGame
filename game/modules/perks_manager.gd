extends GameManagerModule

var player_perk_choice_counts: Dictionary
var active_perk_executions: Array[PerkExecution]

const DISTANCE_PERK_POOLS = [
	preload("res://perks/pools/distance_1_perk_pool.tres"),
	preload("res://perks/pools/distance_2_perk_pool.tres"),
	preload("res://perks/pools/distance_3_perk_pool.tres"),
	preload("res://perks/pools/distance_4_perk_pool.tres"),
	preload("res://perks/pools/distance_5_perk_pool.tres")
]
const USE_DEBUG_PERK_POOL: bool = true
const DEBUG_PERK_POOL = preload("res://perks/pools/debug_perk_pool.tres")

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


# Returning a Resource instead of PerkPool due to a really fucking
# weird GDScript bug lol. Might be fixed eventually..?
func _get_distance_perk_pool(distance: int) -> Resource:
	if USE_DEBUG_PERK_POOL:
		return DEBUG_PERK_POOL
	else:
		for distance_perk_pool in DISTANCE_PERK_POOLS:
			if distance < distance_perk_pool.max_distance:
				return distance_perk_pool
		
		return DISTANCE_PERK_POOLS[DISTANCE_PERK_POOLS.size() - 1]


func execute_perk(perk: Perk, executor_player: Player):
	var execution_script = perk.execution_script.new()
	execution_script.game_manager = game_manager
	execution_script.perk = perk
	execution_script.executor_player = executor_player
	
	active_perk_executions.append(execution_script)
	execution_script._on_activate()


func clear_all_active_perk_executions():
	for active_perk_execution in active_perk_executions:
		active_perk_execution._on_deactivate()
	active_perk_executions.clear()


func perform_deactivation_event(deactivation_event: Perk.DeactivationEvent):
	var active_perk_executions_copy = active_perk_executions.duplicate()
	for active_perk_execution in active_perk_executions_copy:
		active_perk_execution._on_deactivate()
		active_perk_executions.erase(active_perk_execution)
