extends AbilityExecution

var current_platform_scene: Node2D

const PLATFORM_SCENE = preload("res://abilities/scenes/platform_scene.tscn")


func _on_button_up() -> bool:
	if current_platform_scene != null:
		return false
	var player_peer_id = player.get_peer_id()
	_place_platform.rpc(player_peer_id)
	return true


@rpc("any_peer", "call_local")
func _place_platform(executor_peer_id: int):
	player.velocity = Vector2.ZERO
	current_platform_scene = PLATFORM_SCENE.instantiate()
	current_platform_scene.global_position = player.global_position + Vector2(0, 96)
	player.ability_nodes.add_child(current_platform_scene)
	await get_tree().create_timer(4.0).timeout
	
	current_platform_scene.queue_free()
	current_platform_scene = null


func _cleanup():
	if current_platform_scene != null and is_instance_valid(current_platform_scene):
		current_platform_scene.queue_free()
