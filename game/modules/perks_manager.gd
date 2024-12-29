extends GameManagerModule

var player_perk_choice_counts: Dictionary
var player_perk_pool_strengths: Dictionary
var active_perk_executions: Array[PerkExecution]


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


func increment_player_perk_pool_strengths():
	var leading_players = game_manager.game_scoring.get_leading_players()
	for player in game_manager.players:
		if leading_players.has(player):
			player_perk_pool_strengths[player] += 0.25 if game_manager.map_number == 1 else 0.5
		else:
			player_perk_pool_strengths[player] += 1


func reset_player_perk_pool_strengths():
	for player in game_manager.players:
		player_perk_pool_strengths[player] = 0


func _get_player_group_by_distance(player: Player):
	var score_difference = game_manager.game_scoring.get_score_difference_from_leading(player)
	
	var group = 1
	for minimum_distance in game_manager.game_settings.perk_pool.group_minimum_distances:
		if score_difference <= minimum_distance:
			break
		else:
			group += 1
	
	return group


func _get_player_perk_pool_group(player: Player):
	var group_by_perk_pool_strength = ceil(player_perk_pool_strengths[player])
	var group_by_distance = _get_player_group_by_distance(player)
	return max(group_by_perk_pool_strength, group_by_distance)


func get_weighted_perks_from_pool(player: Player, perk_count: int):
	print(player.get_display_name(), " - Group Used: ", _get_player_perk_pool_group(player))
	return game_manager.game_settings.perk_pool.get_weighted_random_perks(
		3, _get_player_perk_pool_group(player), false
	)


func _get_distance_from_leading_player(player: Player) -> int:
	var leading_players = game_manager.game_scoring.get_leading_players()
	if leading_players.size() == 0: return 0
	
	var leading_player_score = game_manager.game_scoring.get_player_score(leading_players[0])
	var player_score = game_manager.game_scoring.get_player_score(player)
	return leading_player_score - player_score


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
