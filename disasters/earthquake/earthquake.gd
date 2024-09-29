extends Disaster

const MAX_PUSH_FORCE = 750.0


var frames: int = 0

func _process(delta):
	if not should_process():
		return
		
	if frames % 10 == 0:
		var x = randf_range(DisasterManager.disaster_area.position.x, DisasterManager.disaster_area.end.x)
		var y = randf_range(DisasterManager.disaster_area.position.y, DisasterManager.disaster_area.end.y)
		_create_zone.rpc_id(1, Vector2(x, y))
		
	frames += 1
	

@rpc("any_peer", "call_local")
func _create_zone(position: Vector2):
	var impact_zone = create_rectangle(250, 100)
	impact_zone = PolygonUtil.get_global_polygon_from_local_space(impact_zone, position)
	
	PhysicsManager.ImpulseBuilder.new()\
		.collision_polygon(impact_zone)\
		.affected_environment_layers([BreakableBody2D.EnvironmentLayer.ALL])\
		.applied_body_impulse(_push_rigid_body.bindv([position]))\
		.applied_damage(2, _push_broken_breakable_body)\
		.execute()


func _push_broken_breakable_body(body: PhysicsBody2D):
	return Vector2.ZERO


func _push_rigid_body(body: PhysicsBody2D, center: Vector2):
	var push_force = _get_push_force(body, center)
	var direction = (body.global_position - (center)).normalized()
	direction.x = 1 if randf() > .5 else -1
	return direction * push_force
	

func _get_push_force(body: PhysicsBody2D, center: Vector2) -> float:
	var distance = center.distance_to(body.global_position)
	var distance_ratio = 1.0 - (distance / 500.0)
	distance_ratio = clamp(distance_ratio, 0.0, 1.0)
	var power_ratio = EasingFunctions.ease_out_circ(0.0, 1.0, distance_ratio)
	return MAX_PUSH_FORCE * power_ratio
