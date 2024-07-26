extends Area2D

var direction: Vector2
var executor_player: Player
var max_push_force: float

@onready var collision_polygon_2d = $CollisionPolygon2D


func setup(direction: Vector2, executor_player: Player, max_push_force: float):
	self.direction = direction
	self.executor_player = executor_player
	self.max_push_force = max_push_force


func _ready():
	# Collision NEEDS to be disabled by default. Strange Godot bug with
	# physics engine if the polygon is edited while the collision is
	# enabled.
	collision_polygon_2d.set_deferred("disabled", false)
	
	print(executor_player)
	global_position = executor_player.get_center_global_position()
	var rotated_polygon: PackedVector2Array
	for point in collision_polygon_2d.polygon:
		rotated_polygon.append(point.rotated(-direction.angle_to(Vector2.RIGHT)))
	collision_polygon_2d.polygon = rotated_polygon
	
	await get_tree().physics_frame
	await get_tree().physics_frame
	var all_created_shards: Array[ShardPiece]
	for overlapping_body in get_overlapping_bodies():
		if overlapping_body is FragileBody2D:
			var created_shards = overlapping_body.break_apart(collision_polygon_2d)
			all_created_shards.append_array(created_shards)
		elif overlapping_body is RigidBody2D:
			_push_rigid_body(overlapping_body)
	
	for shard in all_created_shards:
		_push_rigid_body(shard as RigidBody2D)
	
	await get_tree().create_timer(1.0).timeout
	call_deferred("queue_free")


func _push_rigid_body(rigid_body: RigidBody2D):
	var push_force = _get_push_force(rigid_body)
	rigid_body.apply_central_impulse(direction * push_force)


func _get_push_force(body: PhysicsBody2D) -> float:
	var distance = global_position.distance_to(body.global_position)
	var distance_ratio = 1.0 - (distance / 500.0)
	distance_ratio = clamp(distance_ratio, 0.0, 1.0)
	var power_ratio = EasingFunctions.ease_out_circ(0.0, 1.0, distance_ratio)
	return max_push_force * power_ratio
