extends AbilityExecution

const DASH_FORCE = 2000.0


func _on_button_down() -> bool:
	var direction = player.controller.get_pointer_direction()
	player.velocity = direction * DASH_FORCE
	_spawn_sprite.rpc(direction)
	return true


@rpc("any_peer", "call_local")
func _spawn_sprite(direction: Vector2):
	var sprite = Sprite2D.new()
	sprite.texture = preload("res://abilities/textures/shitty_dash_texture.png")
	sprite.rotation = -direction.angle_to(Vector2.RIGHT)
	player.add_child(sprite)
	await get_tree().create_timer(0.75).timeout
	
	sprite.queue_free()
