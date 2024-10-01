class_name ShardMultiplayerSynchronizer extends Node

var sync_timer: Timer
var last_position: Vector2
var last_rotation: float
var last_linear_velocity: Vector2
var last_angular_velocity: float


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
	if get_parent().position != last_position:
		return true
	elif get_parent().rotation != last_rotation:
		return true
	elif get_parent().linear_velocity != last_linear_velocity:
		return true
	elif get_parent().angular_velocity != last_angular_velocity:
		return true
	else:
		return false
