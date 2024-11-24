extends GameState

var is_first_disaster: bool
var countdown: float


func _enter():
	game_scene.revive_dead_players.rpc_id(1)
	
	is_first_disaster = game_scene.current_disaster_number == 1
	if is_first_disaster: countdown = game_scene.game_manager.game_settings.time_before_first_disaster
	else: countdown = game_scene.game_manager.game_settings.time_inbetween_disasters
	game_scene.map_progress_ui.update_disaster_icons.rpc(game_scene.current_map_disasters, game_scene.current_disaster_number, false)


func _update(delta):
	if countdown <= 0.0:
		game_scene.transition_to_state("disaster")
	else:
		game_scene.map_progress_ui.set_countdown_to_disaster_text.rpc(ceil(countdown), is_first_disaster)
		countdown -= delta
