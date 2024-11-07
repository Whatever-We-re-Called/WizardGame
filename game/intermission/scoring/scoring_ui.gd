extends CenterContainer

@onready var player_score_cards_node: VBoxContainer = %PlayerScoreCards

var player_score_cards: Dictionary


@rpc("authority", "call_local", "reliable")
func create_player_score_cards(players: Array[Player]):
	for player in players:
		var player_score_card = preload("res://game/intermission/scoring/player_score_card.tscn").instantiate()
		# TODO init card
		add_child(player_score_card)
		
		player_score_cards[player] = player_score_card
