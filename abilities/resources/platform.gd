extends AbilityExecution

var current_platform_scene: Node2D

const PLATFORM_SCENE = preload("res://abilities/scenes/platform_scene.tscn")


func _handle_input(player: Player, button_input: String):
	if Input.is_action_just_pressed(button_input):
		if current_platform_scene == null:
			if not is_on_cooldown():
				var player_peer_id = player.get_peer_id()
				_place_platform.rpc(player_peer_id)
				start_cooldown()


@rpc("any_peer", "call_local")
func _place_platform(executor_peer_id: int):
	var executor_player = get_executor_player()
	
	executor_player.velocity = Vector2.ZERO
	current_platform_scene = PLATFORM_SCENE.instantiate()
	current_platform_scene.global_position = executor_player.global_position + Vector2(0, 96)
	executor_player.ability_nodes.add_child(current_platform_scene)
	await get_tree().create_timer(4.0).timeout
	
	current_platform_scene.queue_free()
	current_platform_scene = null
