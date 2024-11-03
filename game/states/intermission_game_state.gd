extends GameState


func _enter():
	game_scene.transition_to_state("mapstart")
