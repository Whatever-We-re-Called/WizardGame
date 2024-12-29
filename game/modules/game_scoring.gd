extends GameManagerModule

var player_scores: Dictionary
var active_survival_bonuses: Dictionary
var queued_scoring_events: Queue = Queue.new()

func reset():
	player_scores = {}
	active_survival_bonuses = {}
	queued_scoring_events.clear()


func get_player_score(player: Player) -> int:
	if player_scores.has(player):
		return player_scores[player]
	else:
		return 0


func get_player_placements() -> Dictionary:
	var result: Dictionary
	
	var unscored_players = game_manager.players.duplicate()
	var current_placement_number = 1
	while unscored_players.size() > 0:
		var leading_players = _get_leading_players_from_list(unscored_players)
		for player in leading_players:
			result[player] = current_placement_number
			unscored_players.erase(player)
		
		current_placement_number += leading_players.size()
	
	return result


# Returns array in the case of a tie. Requires whatever 
# calls it to account for that case.
func get_leading_players() -> Array[Player]:
	return _get_leading_players_from_list(game_manager.players)


func _get_leading_players_from_list(players_list: Array[Player]) -> Array[Player]:
	var result: Array[Player]
	
	for player in players_list:
		if result.size() > 0:
			if get_player_score(player) > get_player_score(result[0]):
				result.clear()
				result.append(player)
			elif get_player_score(player) == get_player_score(result[0]):
				result.append(player)
		else:
			result.append(player)
	
	return result
	


func get_highest_player_score() -> int:
	var leading_players = get_leading_players()
	if leading_players.size() > 0:
		return get_player_score(leading_players[0])
	else:
		return 0


func get_score_difference_from_leading(player: Player):
	var leading_score = get_player_score(get_leading_players()[0])
	var player_score = get_player_score(player)
	return abs(leading_score - player_score)


func set_survival_bonus(player: Player, bonus: int):
	active_survival_bonuses[player] = bonus


func add_survival_bonus(player: Player, added_bonus: int):
	if active_survival_bonuses.has(player):
		active_survival_bonuses[player] += added_bonus
	else:
		active_survival_bonuses[player] = added_bonus


func remove_survival_bonus(player: Player, removed_bonus: int):
	if active_survival_bonuses.has(player):
		active_survival_bonuses[player] -= removed_bonus


func clear_survival_bonuses():
	active_survival_bonuses = {}


func add_player_score(player: Player, added_score: int):
	if player_scores.has(player):
		player_scores[player] += added_score
	else:
		player_scores[player] = added_score


func queue_survival_scoring_event(survived_players: Array[Player], severity: DisasterManager.Severity):
	const SEVERITY_SURVIVAL_SCORING_EVENTS = {
		DisasterManager.Severity.ONE: preload("res://game/scoring_events/severity_one_survival_scoring_event.tres"),
		DisasterManager.Severity.TWO: preload("res://game/scoring_events/severity_two_survival_scoring_event.tres"),
		DisasterManager.Severity.THREE: preload("res://game/scoring_events/severity_three_survival_scoring_event.tres"),
		DisasterManager.Severity.FOUR: preload("res://game/scoring_events/severity_four_survival_scoring_event.tres"),
		DisasterManager.Severity.FIVE: preload("res://game/scoring_events/severity_five_survival_scoring_event.tres")
	}
	
	var scoring_event = SEVERITY_SURVIVAL_SCORING_EVENTS[severity].duplicate()
	scoring_event.rewarded_players = survived_players
	
	queued_scoring_events.enqueue(scoring_event)
	
	_queue_survival_bonus_scoring_event(survived_players, 1, preload("res://game/scoring_events/bonus_one_survival_scoring_event.tres"))
	_queue_survival_bonus_scoring_event(survived_players, 2, preload("res://game/scoring_events/bonus_two_survival_scoring_event.tres"))
	_queue_survival_bonus_scoring_event(survived_players, 3, preload("res://game/scoring_events/bonus_three_survival_scoring_event.tres"))
	
	_queue_sole_survivor_scoring_event(survived_players)


func _queue_survival_bonus_scoring_event(survived_players: Array[Player], bonus: int, bonus_scoring_event: ScoringEvent):
	var scoring_event = bonus_scoring_event.duplicate()
	for player in survived_players:
		if active_survival_bonuses.has(player):
			if active_survival_bonuses[player] == bonus:
				scoring_event.rewarded_players.append(player)
	
	if scoring_event.rewarded_players.size() > 0:
		queued_scoring_events.enqueue(scoring_event)


func _queue_sole_survivor_scoring_event(survived_players: Array[Player]):
	if game_manager.players.size() >= 3 and survived_players.size() == 1:
		var scoring_event = preload("res://game/scoring_events/sole_survivor_scoring_event.tres").duplicate()
		scoring_event.rewarded_players = survived_players
		queued_scoring_events.enqueue(scoring_event)
