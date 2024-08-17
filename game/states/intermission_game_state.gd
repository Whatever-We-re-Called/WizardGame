extends GameState


func _enter():
	game_manager.transition_to_state("mapstart")
