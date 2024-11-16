extends CenterContainer

var player_score_cards: Dictionary


@rpc("authority", "call_local", "reliable")
func create_player_score_card(peer_id: int, player_name: String, player_score: int, goal_score: int):
	var player_score_card = preload("res://game/intermission/scoring/player_score_card.tscn").instantiate()
	player_score_card.setup(player_name, player_score, goal_score)
	%PlayerScoreCards.add_child(player_score_card)
	
	player_score_cards[peer_id] = player_score_card
