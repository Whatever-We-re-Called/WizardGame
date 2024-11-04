extends GameState


func _enter():
	game_scene.change_to_scene("res://game/intermission/intermission_scene.tscn")
	game_scene.transition_to_state("intermissionscoring ")
