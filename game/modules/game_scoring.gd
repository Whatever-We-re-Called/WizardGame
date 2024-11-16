extends Node

var player_scores: Dictionary
var queued_scoring_events: Queue = Queue.new()

func reset():
	player_scores = {}
	queued_scoring_events.clear()


func get_player_score(player: Player) -> int:
	if player_scores.has(player):
		return player_scores[player]
	else:
		return 0


func add_player_score(player: Player, added_score: int):
	if player_scores.has(player):
		player_scores[player] += added_score
	else:
		player_scores[player] = added_score


func queue_survival_scoring_event(survived_players: Array[Player], severity: DisasterManager.Severity):
	const SEVERITY_SURVIVAL_SCORING_EVENTS = {
		DisasterManager.Severity.ONE: preload("res://game/scoring_events/severity_1_survival_scoring_event.tres"),
		DisasterManager.Severity.TWO: preload("res://game/scoring_events/severity_2_survival_scoring_event.tres"),
		DisasterManager.Severity.THREE: preload("res://game/scoring_events/severity_3_survival_scoring_event.tres"),
		DisasterManager.Severity.FOUR: preload("res://game/scoring_events/severity_4_survival_scoring_event.tres"),
		DisasterManager.Severity.FIVE: preload("res://game/scoring_events/severity_5_survival_scoring_event.tres")
	}
	
	var scoring_event = SEVERITY_SURVIVAL_SCORING_EVENTS[severity].duplicate()
	scoring_event.rewarded_players = survived_players
	
	queued_scoring_events.enqueue(scoring_event)
