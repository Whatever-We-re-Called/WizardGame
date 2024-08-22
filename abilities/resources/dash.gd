extends AbilityExecution

const DASH_FORCE = 2000.0


func _handle_input(player: Player, button_input: String):
	if Input.is_action_just_pressed(button_input) and not is_on_cooldown():
		var player_peer_id = player.get_peer_id()
		var direction = player.get_pointer_direction()
		_execute_dash(direction)
		_spawn_sprite.rpc(direction)
		start_cooldown()


func _execute_dash(direction: Vector2):
	var executor_player = get_executor_player()
	
	executor_player.velocity = direction * DASH_FORCE


@rpc("any_peer", "call_local")
func _spawn_sprite(direction: Vector2):
	var executor_player = get_executor_player()
	
	var sprite = Sprite2D.new()
	sprite.texture = preload("res://abilities/textures/shitty_dash_texture.png")
	sprite.rotation = -direction.angle_to(Vector2.RIGHT)
	executor_player.add_child(sprite)
	await get_tree().create_timer(0.75).timeout
	
	sprite.queue_free()
