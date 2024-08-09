extends AbilityExecution

var current_remote_land_mine_scene: Node2D

const MAX_PUSH_FORCE = 750.0
const REMOTE_LAND_MINE_SCENE = preload("res://abilities/scenes/remote_land_mine_scene.tscn")

func _handle_input(player: Player, button_input: String):
	if Input.is_action_just_pressed(button_input):
		if current_remote_land_mine_scene == null:
			if not is_on_cooldown():
				_place_remote_land_mine.rpc(player.get_peer_id())
		else:
			_explode_remote_land_mine.rpc()
			start_cooldown()


@rpc("any_peer", "call_local")
func _place_remote_land_mine(executor_peer_id: int):
	var executor_player = get_executor_player()
	
	current_remote_land_mine_scene = REMOTE_LAND_MINE_SCENE.instantiate()
	current_remote_land_mine_scene.global_position = executor_player.global_position
	executor_player.ability_nodes.add_child(current_remote_land_mine_scene)
	current_remote_land_mine_scene.add_collision_exception_with(executor_player)
	current_remote_land_mine_scene.button_area.body_entered.connect(_remote_land_mine_triggered)


@rpc("any_peer", "call_local")
func _explode_remote_land_mine():
	var remote_land_mine_global_position = current_remote_land_mine_scene.global_position
	current_remote_land_mine_scene.call_deferred("queue_free")
	
	var executor_player = get_executor_player()
	
	var area = Area2D.new()
	PhysicsUtil.set_environment_mask_to_all(area)
	area.set_collision_mask_value(5, true)
	area.global_position = current_remote_land_mine_scene.global_position
	var collision_polygon = CollisionPolygon2D.new()
	collision_polygon.polygon = PolygonUtil.get_polygon_from_radius(16, 175.0)
	area.add_child(collision_polygon)
	var sprite = Sprite2D.new()
	sprite.texture = preload("res://abilities/textures/shitty_remote_land_mine_explosion_texture.png")
	area.add_child(sprite)
	call_deferred("add_child", area)
	
	await get_tree().physics_frame
	await get_tree().physics_frame
	var all_created_shards: Array[ShardPiece]
	for overlapping_body in area.get_overlapping_bodies():
		var direction = (overlapping_body.global_position - remote_land_mine_global_position).normalized()
		if overlapping_body is FragileBody2D:
			var created_shards = overlapping_body.break_apart(collision_polygon)
			all_created_shards.append_array(created_shards)
		elif overlapping_body is RigidBody2D:
			_push_rigid_body(overlapping_body, executor_player, direction)
		elif overlapping_body is Player:
			_push_player(overlapping_body, executor_player, direction)
	
	for shard in all_created_shards:
		if shard is RigidBody2D:
			var direction = (shard.global_position - remote_land_mine_global_position).normalized()
			_push_rigid_body(shard, executor_player, direction)
	
	await get_tree().create_timer(1.0).timeout
	area.call_deferred("queue_free")


func _push_rigid_body(rigid_body: RigidBody2D, executor_player: Player, direction: Vector2):
	var push_force = _get_push_force(rigid_body, executor_player)
	rigid_body.apply_central_impulse(direction * push_force)


func _push_player(player: Player, executor_player: Player, direction: Vector2):
	var push_force = _get_push_force(player, executor_player) * 2.5
	player.velocity = Vector2.ZERO
	player.apply_central_impulse(direction * push_force)

# TODO Revisit game feel of this (literally just inappropriately copied
# from wind_gust.gd.
func _get_push_force(body: PhysicsBody2D, executor_player: Player) -> float:
	var distance = executor_player.global_position.distance_to(body.global_position)
	var distance_ratio = 1.0 - (distance / 500.0)
	distance_ratio = clamp(distance_ratio, 0.0, 1.0)
	var power_ratio = EasingFunctions.ease_out_circ(0.0, 1.0, distance_ratio)
	return MAX_PUSH_FORCE * power_ratio


func _remote_land_mine_triggered(body: Node):
	if body != get_executor_player() and body != current_remote_land_mine_scene:
		_explode_remote_land_mine.rpc()
