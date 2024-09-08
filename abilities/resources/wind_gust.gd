extends AbilityExecution

const MAX_PUSH_FORCE = 750.0


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
	
	PhysicsManager.ImpulseBuilder.new()\
		.collision_polygon(calculated_polygon)\
		.affected_environment_layers([BreakableBody2D.EnvironmentLayer.ALL])\
		.applied_body_impulse(_push_body.bindv([executor_player, direction]))\
		.applied_player_impulse(_push_player.bindv([executor_player, direction]))\
		.excluded_players([executor_player])\
		.cleanup_time(1.0)\
		.execute()


func _push_body(rigid_body: RigidBody2D, executor_player: Player, direction: Vector2) -> Vector2:
	var push_force = _get_push_force(rigid_body, executor_player)
	return direction * push_force


func _push_player(player: Player, executor_player: Player, direction: Vector2) -> Vector2:
	var push_force = _get_push_force(player, executor_player) *  3.0
	return direction * push_force


func _get_push_force(body: PhysicsBody2D, executor_player: Player) -> float:
	var distance = executor_player.global_position.distance_to(body.global_position)
	var distance_ratio = 1.0 - (distance / 500.0)
	distance_ratio = clamp(distance_ratio, 0.0, 1.0)
	var power_ratio = EasingFunctions.ease_out_circ(0.0, 1.0, distance_ratio)
	return MAX_PUSH_FORCE * power_ratio
