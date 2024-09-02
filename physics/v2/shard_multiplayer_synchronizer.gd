class_name ShardMultiplayerSynchronizer extends Node

var sync_timer: Timer
var last_position: Vector2
var last_rotation: float
var last_linear_velocity: Vector2
var last_angular_velocity: float

const DELTA_LINEAR_CHANGE: float = 5.0
const DELTA_ANGULAR_CHANGE: float = deg_to_rad(2.5)


func _physics_process(delta: float) -> void:
	if multiplayer.is_server():
		_execute_sync()


func _execute_sync():
	if _has_physics_changed():
		PhysicsManager.append_shard_sync_data(get_parent())
		last_position = get_parent().position
		last_rotation = get_parent().rotation
		last_linear_velocity = get_parent().linear_velocity
		last_angular_velocity = get_parent().angular_velocity


func _has_physics_changed() -> bool:
	if get_parent().position.distance_to(last_position) >= DELTA_LINEAR_CHANGE:
		return true
	elif abs(get_parent().rotation - last_rotation) >= DELTA_ANGULAR_CHANGE:
		return true
	elif get_parent().linear_velocity.distance_to(last_linear_velocity) >= DELTA_LINEAR_CHANGE:
		return true
	elif abs(get_parent().angular_velocity - last_angular_velocity) >= DELTA_ANGULAR_CHANGE:
		return true
	else:
		return false
