extends CenterContainer

@rpc("authority", "call_local", "reliable")
func setup():
	%ContinueButton.visible = multiplayer.is_server()
	%WaitingForHostLabel.visible = not multiplayer.is_server()


@rpc("authority", "call_local", "reliable")
func create_player_result_card(player_name: String, placement: int, score: int):
	var player_result_card = preload("res://game/intermission/results/player_result_card.tscn").instantiate()
	player_result_card.setup(player_name, placement, score)
	%PlayerScoreCards.add_child(player_result_card)


func _on_continue_button_pressed() -> void:
	pass # Replace with function body.
