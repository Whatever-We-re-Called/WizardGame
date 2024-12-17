extends SpellExecution

var current_wayback_point_scene: Node2D

const WAYBACK_POINT_SCENE = preload("res://spells/scenes/wayback_point_scene.tscn")


func _on_button_down() -> bool:
	if current_wayback_point_scene == null:
		_place_wayback_point_scene.rpc(player.get_peer_id())
		return false
	else:
		_teleport_player_to_wayback_point.rpc(player.get_peer_id())
		return true


@rpc("any_peer", "call_local")
func _place_wayback_point_scene(executor_peer_id: int):
	current_wayback_point_scene = WAYBACK_POINT_SCENE.instantiate()
	current_wayback_point_scene.global_position = player.global_position
	player.spell_nodes.add_child(current_wayback_point_scene)


@rpc("any_peer", "call_local")
func _teleport_player_to_wayback_point(executor_peer_id: int):
	player.global_position = current_wayback_point_scene.global_position
	player.velocity = Vector2.ZERO
	
	current_wayback_point_scene.queue_free()


func _cleanup():
	if current_wayback_point_scene != null and is_instance_valid(current_wayback_point_scene):
		current_wayback_point_scene.queue_free()
