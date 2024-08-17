extends Disaster

const MAX_PUSH_FORCE = 750.0
const LIGHTNING_IMPACT_RADIUS = 150

var should_spawn_lightning = false

var lightning_count = 0
var target_lightning_count = 0


func on_start():
	lightning_count = 0
	target_lightning_count = randi_range(10, 15)
	_do_lightning_delay()


func _process(delta):
	if not should_process():
		return
		
	if should_spawn_lightning:
		if lightning_count >= target_lightning_count:
			stop()
		else:
			spawn_lightning()
			lightning_count += 1
		
		
func spawn_lightning():
	should_spawn_lightning = false
	
	var location: Vector2
	var tries = 0
	while location == Vector2.ZERO and tries < 10:
		tries += 1
		
		var x = randi_range(DisasterManager.disaster_area.position.x, DisasterManager.disaster_area.end.x)
		var y = DisasterManager.disaster_area.position.y
		var areas = []
		while y < DisasterManager.disaster_area.end.y:
			var temp_pos = Vector2(x, y)
			areas.append(_create_test_overlap_area(temp_pos))
			y += 5
			
		await get_tree().physics_frame
		await get_tree().physics_frame
			
		areas = areas.filter(func f(_area): return _has_overlap(_area))
		if not areas.is_empty():
			location = areas[0].get_child(0).polygon[0]
			
	if location == Vector2.ZERO:
		_get_random_player_pos()
	
	_spawn_lightning.rpc(location, randi_range(-30, 30), randi_range(-45, 45))
	_do_lightning_delay()
	
	
func _get_random_player_pos():
	pass # TODO
	
	
func _create_test_overlap_area(pos):
	var polygon: PackedVector2Array = [
		Vector2(0, 10),
		Vector2(0, -10),
		Vector2(20, 10),
		Vector2(20, -10)
	]
	polygon = PolygonUtil.get_global_polygon_from_local_space(polygon, pos)
			
	var area = Area2D.new()
	PhysicsUtil.set_environment_mask_to_all(area)
	area.set_collision_mask_value(5, true)
	var collision_polygon = CollisionPolygon2D.new()
	collision_polygon.polygon = polygon
	area.add_child(collision_polygon)
	
	DisasterManager.disaster_nodes.add_child(area)
	
	return area
	
func _has_overlap(area) -> bool:
	var has_overlap: bool = false
	for body in area.get_overlapping_bodies():
		if body is FragileBody2D or body is RigidBody2D or body is Player:
			has_overlap = true
			break
	
	DisasterManager.disaster_nodes.remove_child(area)
	return has_overlap
	
	
func _do_lightning_delay():
	await get_tree().create_timer(_get_lightning_delay()).timeout
	should_spawn_lightning = true


func _get_lightning_delay() -> float:
	return randf_range(.75, 2.5)


@rpc("any_peer", "call_local")
func _spawn_lightning(position: Vector2, rotation_degrees: float, impact_rotation_degrees: float):
	var impact_zone = create_regular_polygon(10, LIGHTNING_IMPACT_RADIUS)
	impact_zone = PolygonUtil.get_rotated_polygon(impact_zone, deg_to_rad(impact_rotation_degrees))
	impact_zone = PolygonUtil.get_global_polygon_from_local_space(impact_zone, position)
	
	var area = Area2D.new()
	PhysicsUtil.set_environment_mask_to_all(area)
	area.set_collision_mask_value(5, true)
	var collision_polygon = CollisionPolygon2D.new()
	collision_polygon.polygon = impact_zone
	area.add_child(collision_polygon)
	
	var lightning = preload("res://disasters/storm/lightning.tscn").instantiate()
	lightning.position = position
	lightning.rotation = deg_to_rad(rotation_degrees)
	
	DisasterManager.disaster_nodes.add_child(area)
	DisasterManager.disaster_nodes.add_child(lightning)
	
	await get_tree().physics_frame
	await get_tree().physics_frame
	var all_created_shards: Array[ShardPiece]
	for overlapping_body in area.get_overlapping_bodies():
		if overlapping_body is FragileBody2D:
			var created_shards = overlapping_body.break_apart(collision_polygon)
			all_created_shards.append_array(created_shards)
		elif overlapping_body is RigidBody2D:
			_push_rigid_body(overlapping_body, position)
		elif overlapping_body is Player:
			_damage_player(overlapping_body)
	
	for shard in all_created_shards:
		if shard is RigidBody2D:
			_push_rigid_body(shard, position)
	
	await get_tree().create_timer(.5).timeout
	lightning.call_deferred("queue_free") 
	
	await get_tree().create_timer(1.0).timeout
	area.call_deferred("queue_free")
	
	
func _push_rigid_body(rigid_body: RigidBody2D, center: Vector2):
	var push_force = _get_push_force(rigid_body, center)
	var direction = (rigid_body.global_position - (center + Vector2(0, 500))).normalized()
	rigid_body.apply_central_impulse(direction * push_force)
	

func _get_push_force(body: PhysicsBody2D, center: Vector2) -> float:
	var distance = center.distance_to(body.global_position)
	var distance_ratio = 1.0 - (distance / 500.0)
	distance_ratio = clamp(distance_ratio, 0.0, 1.0)
	var power_ratio = EasingFunctions.ease_out_circ(0.0, 1.0, distance_ratio)
	return MAX_PUSH_FORCE * power_ratio
	
	
func _damage_player(player):
	pass # TODO
	
