extends IntermissionUI

var player_score_cards: Dictionary


@rpc("authority", "call_local", "reliable")
func create_player_score_card(peer_id: int, player_name: String, player_score: int, goal_score: int):
	var player_score_card = preload("res://game/intermission/scoring/player_score_card.tscn").instantiate()
	player_score_card.setup(player_name, player_score, goal_score)
	%PlayerScoreCards.add_child(player_score_card)
	
	player_score_cards[peer_id] = player_score_card


@rpc("authority", "call_local", "reliable")
func update_player_score_card(peer_id: int, player_score: int):
	var player_score_card = player_score_cards[peer_id]
	player_score_card.update(player_score)


@rpc("authority", "call_local", "reliable")
func clear_scoring_event_text():
	%ScoringEventTitleLabel.text = ""
	%ScoringEventSubtitleLabel.text = ""


@rpc("authority", "call_local", "reliable")
func set_scoring_event_text(title_text: String, subtitle_text: String, color: Color):
	%ScoringEventTitleLabel.text = title_text
	%ScoringEventTitleLabel.label_settings.font_color = color
	%ScoringEventSubtitleLabel.text = subtitle_text
	%ScoringEventSubtitleLabel.label_settings.font_color = color
