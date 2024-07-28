extends AbilityExecution

const MAX_PUSH_FORCE = 500.0


func _handle_input(player: Player, button_input: String):
	if Input.is_action_just_pressed(button_input):
		var direction = player.get_pointer_direction()
		_calculate_wind_gust.rpc_id(1, player.get_peer_id(), direction)


@rpc("any_peer", "call_local")
func _calculate_wind_gust(executor_peer_id: int, direction: Vector2):
	var executor_player = get_player(executor_peer_id)
	
	var origin_polygon: PackedVector2Array = [
		Vector2(0, 100),
		Vector2(0, -100),
		Vector2(500, -125),
		Vector2(500, 125)
	]
	var rotated_polygon: PackedVector2Array
	for point in origin_polygon:
		rotated_polygon.append(point.rotated(-direction.angle_to(Vector2.RIGHT)))
	var calculated_polygon = PolygonUtil.get_global_polygon_from_local_space(rotated_polygon, executor_player.get_center_global_position())
	
	var area = Area2D.new()
	var collision_polygon = CollisionPolygon2D.new()
	collision_polygon.polygon = calculated_polygon
	area.add_child(collision_polygon)
	add_child(area)
	
	await get_tree().physics_frame
	await get_tree().physics_frame
	var all_created_shards: Array[ShardPiece]
	for overlapping_body in area.get_overlapping_bodies():
		if overlapping_body is FragileBody2D:
			var created_shards = overlapping_body.break_apart(collision_polygon)
			all_created_shards.append_array(created_shards)
		elif overlapping_body is RigidBody2D:
			_push_rigid_body(overlapping_body, direction)
	
	for shard in all_created_shards:
		_push_rigid_body(shard as RigidBody2D, direction)
	
	await get_tree().create_timer(1.0).timeout
	collision_polygon.call_deferred("queue_free")


func _push_rigid_body(rigid_body: RigidBody2D, direction: Vector2):
	var push_force = _get_push_force(rigid_body)
	rigid_body.apply_central_impulse(direction * push_force)


func _get_push_force(body: PhysicsBody2D) -> float:
	var distance = global_position.distance_to(body.global_position)
	var distance_ratio = 1.0 - (distance / 500.0)
	distance_ratio = clamp(distance_ratio, 0.0, 1.0)
	var power_ratio = EasingFunctions.ease_out_circ(0.0, 1.0, distance_ratio)
	return MAX_PUSH_FORCE * power_ratio
