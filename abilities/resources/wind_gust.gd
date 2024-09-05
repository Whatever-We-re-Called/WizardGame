extends AbilityExecution

const PUSH_FORCE = 750.0


func _handle_input(player: Player, button_input: String):
	if Input.is_action_just_pressed(button_input) and not is_on_cooldown():
		var direction = player.get_pointer_direction()
		_calculate_wind_gust.rpc_id(1, player.get_peer_id(), direction)
		start_cooldown()


@rpc("any_peer", "call_local")
func _calculate_wind_gust(executor_peer_id: int, direction: Vector2):
	var executor_player = get_executor_player()
	
	var original_polygon: PackedVector2Array = [
		Vector2(0, 100),
		Vector2(0, -100),
		Vector2(500, -125),
		Vector2(500, 125)
	]
	var rotated_polygon = PolygonUtil.get_rotated_polygon(original_polygon, -direction.angle_to(Vector2.RIGHT))
	var calculated_polygon = PolygonUtil.get_global_polygon_from_local_space(rotated_polygon, executor_player.get_center_global_position())
	
	_execute_wind_gust.rpc(calculated_polygon, executor_peer_id, direction)


@rpc("any_peer", "call_local")
func _execute_wind_gust(calculated_polygon: PackedVector2Array, executor_peer_id: int, direction: Vector2):
	var executor_player = get_executor_player()
	
	BreakablePhysicsUtil.CollisionBuilder.new()\
		.collision_polygon(calculated_polygon)\
		.affected_environment_layers([BreakableBody2D.EnvironmentLayer.ALL])\
		.applied_body_impulse(_push_body.bindv([executor_player, direction]))\
		.applied_player_impulse(_push_player.bindv([executor_player, direction]))\
		.excluded_players([executor_player])\
		.cleanup_time(1.0)\
		.execute()
	
	var area = Area2D.new()
	PhysicsManager.set_environment_mask_to_all(area)
	area.set_collision_mask_value(5, true)
	var collision_polygon = CollisionPolygon2D.new()
	collision_polygon.polygon = calculated_polygon
	area.add_child(collision_polygon)
	var sprite = Sprite2D.new()
	sprite.global_position = executor_player.global_position
	sprite.rotation = -direction.angle_to(Vector2.RIGHT)
	sprite.texture = preload("res://abilities/textures/shitty_wind_gust_texture.png")
	sprite.offset = Vector2(250, 0)
	area.add_child(sprite)
	add_child(area)
	
	await get_tree().physics_frame
	await get_tree().physics_frame
	var all_created_shards: Array[PhysicsBody2D]
	for overlapping_body in area.get_overlapping_bodies():
		if overlapping_body is BreakableBody2D:
			overlapping_body.break_apart_from_collision(collision_polygon, Vector2.ZERO)
		else:
			if overlapping_body is FragileBody2D:
				var created_shards = overlapping_body.break_apart(collision_polygon)
				all_created_shards.append_array(created_shards)
			elif overlapping_body is RigidBody2D:
				_push_rigid_body(overlapping_body, executor_player, direction)
			elif overlapping_body is Player and overlapping_body != executor_player:
				_push_player(overlapping_body, executor_player, direction)
	
	for shard in all_created_shards:
		if shard is RigidBody2D:
			_push_rigid_body(shard, executor_player, direction)
	
	await get_tree().create_timer(1.0).timeout
	area.call_deferred("queue_free")


func _push_body(rigid_body: RigidBody2D, executor_player: Player, direction: Vector2):
	var push_force = _get_push_force(rigid_body, executor_player)
	rigid_body.apply_central_impulse(direction * push_force)


func _push_player(player: Player, executor_player: Player, direction: Vector2):
	var push_force = _get_push_force(player, executor_player) *  3.0
	player.velocity = Vector2.ZERO
	player.apply_central_impulse(direction * push_force)


func _get_push_force(body: PhysicsBody2D, executor_player: Player) -> float:
	var distance = executor_player.global_position.distance_to(body.global_position)
	var distance_ratio = 1.0 - (distance / 500.0)
	distance_ratio = clamp(distance_ratio, 0.0, 1.0)
	var power_ratio = EasingFunctions.ease_out_circ(0.0, 1.0, distance_ratio)
	return MAX_PUSH_FORCE * power_ratio
