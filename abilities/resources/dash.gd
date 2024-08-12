extends AbilityExecution

const DASH_FORCE = 2000.0


func _handle_input(player: Player, button_input: String):
	if Input.is_action_just_pressed(button_input) and not is_on_cooldown():
		var player_peer_id = player.get_peer_id()
		var direction = player.get_pointer_direction()
		_execute_dash.rpc_id(player_peer_id, player_peer_id, direction)
		start_cooldown()


@rpc("any_peer", "call_local")
func _execute_dash(executor_peer_id: int, direction: Vector2):
	var executor_player = get_executor_player()
	print(direction * DASH_FORCE)
	
	executor_player.velocity = direction * DASH_FORCE
	
	var sprite = Sprite2D.new()
	sprite.texture = preload("res://abilities/textures/shitty_dash_texture.png")
	sprite.rotation = -direction.angle_to(Vector2.RIGHT)
	executor_player.add_child(sprite)
	await get_tree().create_timer(0.75).timeout
	
	sprite.queue_free()
