extends AbilityExecution

const WIND_GUST_AREA = preload("res://abilities/scenes/wind_gust_area.tscn")


@rpc("any_peer", "call_local")
func _on_button_down(executor_peer_id: int):
	var executor_player = get_parent().get_parent()
	var direction = executor_player.get_center_global_position().direction_to(executor_player.get_global_mouse_position())
	direction = direction.normalized()
	
	var wind_gust_area = WIND_GUST_AREA.instantiate()
	wind_gust_area.setup(direction, executor_player, 1000.0)
	executor_player.add_child(wind_gust_area)
