class_name AbilityExecution extends Node2D


func _handle_input(player: Player, button_input: String):
	pass


func get_executor_player() -> Player:
	# TODO Improve this. Will require a better session/game handling
	# system, I think. This works for now.
	return get_parent().get_parent()
