extends AbilityExecution

var current_wayback_point_scene: Node2D

const WAYBACK_POINT_SCENE = preload("res://abilities/scenes/wayback_point_scene.tscn")


func _handle_input(player: Player, button_input: String):
	if Input.is_action_just_pressed(button_input):
		if current_wayback_point_scene == null:
			_place_wayback_point_scene.rpc(player.get_peer_id())
		else:
			_teleport_player_to_wayback_point.rpc(player.get_peer_id())


@rpc("any_peer", "call_local")
func _place_wayback_point_scene(executor_peer_id: int):
	var executor_player = get_executor_player()
	
	current_wayback_point_scene = WAYBACK_POINT_SCENE.instantiate()
	current_wayback_point_scene.global_position = executor_player.global_position
	executor_player.ability_nodes.add_child(current_wayback_point_scene)


@rpc("any_peer", "call_local")
func _teleport_player_to_wayback_point(executor_peer_id: int):
	var executor_player = get_executor_player()
	
	executor_player.global_position = current_wayback_point_scene.global_position
	executor_player.velocity = Vector2.ZERO
	
	current_wayback_point_scene.queue_free()
