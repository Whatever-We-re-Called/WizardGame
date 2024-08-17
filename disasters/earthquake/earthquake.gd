extends Disaster

const MAX_PUSH_FORCE = 750.0


var frames: int = 0

func _process(delta):
	if not should_process():
		return
		
	if frames % 10 == 0:
		var x = randf_range(DisasterManager.disaster_area.position.x, DisasterManager.disaster_area.end.x)
		var y = randf_range(DisasterManager.disaster_area.position.y, DisasterManager.disaster_area.end.y)
		_create_zone.rpc(Vector2(x, y))
		
	frames += 1
	

@rpc("any_peer", "call_local")
func _create_zone(position: Vector2):
	var impact_zone = create_rectangle(250, 100)
	impact_zone = PolygonUtil.get_global_polygon_from_local_space(impact_zone, position)
	
	var area = Area2D.new()
	PhysicsUtil.set_environment_mask_to_all(area)
	area.set_collision_mask_value(5, true)
	var collision_polygon = CollisionPolygon2D.new()
	collision_polygon.polygon = impact_zone
	area.add_child(collision_polygon)

	DisasterManager.disaster_nodes.add_child(area)
	
	await get_tree().physics_frame
	await get_tree().physics_frame
	var all_created_shards: Array[ShardPiece]
	for overlapping_body in area.get_overlapping_bodies():
		if overlapping_body is FragileBody2D:
			var created_shards = overlapping_body.damage_with_collision(2, collision_polygon)
			all_created_shards.append_array(created_shards)
		elif overlapping_body is RigidBody2D:
			_push_rigid_body(overlapping_body, position)
	
	for shard in all_created_shards:
		if shard is RigidBody2D:
			_push_rigid_body(shard, position)
	
	await get_tree().create_timer(0.25).timeout
	area.call_deferred("queue_free")
	
	
func _push_rigid_body(rigid_body: RigidBody2D, center: Vector2):
	var push_force = _get_push_force(rigid_body, center)
	var direction = (rigid_body.global_position - (center)).normalized()
	direction.x = 1 if randf() > .5 else -1
	rigid_body.apply_central_impulse(direction * push_force)
	

func _get_push_force(body: PhysicsBody2D, center: Vector2) -> float:
	var distance = center.distance_to(body.global_position)
	var distance_ratio = 1.0 - (distance / 500.0)
	distance_ratio = clamp(distance_ratio, 0.0, 1.0)
	var power_ratio = EasingFunctions.ease_out_circ(0.0, 1.0, distance_ratio)
	return MAX_PUSH_FORCE * power_ratio
