extends Node

@onready var physics_collision_channels: Node = $PhysicsCollisionChannels

var active_shards: Dictionary
var shard_sync_data: Array


func _physics_process(delta: float):
	if multiplayer.is_server():
		_handle_shard_position_sync()


func _handle_shard_position_sync():
	var compressed_data = MultiplayerUtil.get_compressed_data(shard_sync_data)
	_handle_shard_position_sync_rpc.rpc(compressed_data)
	shard_sync_data.clear()


@rpc("authority", "call_local", "unreliable")
func _handle_shard_position_sync_rpc(compressed_data: PackedByteArray):
	var data = MultiplayerUtil.get_decompressed_data(compressed_data)
	for entry in data:
		var shard = get_tree().root.get_node(active_shards[entry[0]])
		if shard != null:
			shard.replicated_position = entry[1]
			shard.replicated_rotation = entry[2]
			shard.replicated_linear_velocity = entry[3]
			shard.replicated_angular_velocity = entry[4]


func append_shard_sync_data(shard: BreakableBody2D):
	shard_sync_data.append([
		shard.id,
		Vector2(snapped(shard.position.x, 0.01), snapped(shard.position.y, 0.01)),
		snapped(shard.rotation, 0.01),
		Vector2(snapped(shard.linear_velocity.x, 0.01), snapped(shard.linear_velocity.y, 0.01)),
		snapped(shard.angular_velocity, 0.01)
	])


func append_active_shard(shard: BreakableBody2D):
	append_active_shard_rpc.rpc(shard.id, shard.get_path())


@rpc("authority", "call_local", "reliable")
func append_active_shard_rpc(id: int, shard_path: String):
	active_shards[id] = shard_path


func get_new_shard_id() -> int:
	var chosen_id = 0
	var rng = RandomNumberGenerator.new()
	while chosen_id == 0 or active_shards.has(chosen_id):
		chosen_id = rng.randi_range(1, 65535)
	
	return chosen_id


func get_collision_channel(collision_polygon: PackedVector2Array) -> Area2D:
	return physics_collision_channels.get_channel(collision_polygon)


func release_collision_channel(area: Area2D):
	physics_collision_channels.release_channel(area)


## Handy utility class for easily and cleanly building impulse events with
## consideration for our custom physics system.
class ImpulseBuilder extends Node:
	var _collision_polygon: PackedVector2Array = []
	var _affected_environment_layers: Array[BreakableBody2D.EnvironmentLayer] = []
	var _applied_impulse: Callable
	var _applied_body_impulse: Callable
	var _applied_player_impulse: Callable
	var _excluded_bodies: Array[PhysicsBody2D] = []
	var _excluded_players: Array[Player] = []
	var _cleanup_time: float = 1.0
	
	
	## Sets the polygon used for the impulse's collision detection.[br]
	## [br]
	## By default, a polygon with no defined points is used.
	func collision_polygon(value: PackedVector2Array) -> ImpulseBuilder:
		self._collision_polygon = value
		return self
	
	
	## Sets the [BreakableBody2D] environment layers checked by the impulse's collision
	## detection. See [enum BreakableBody2D.EnvironmentLayer] for values.[br]
	## [br]
	## By default, no environment layers are checked.
	func affected_environment_layers(value: Array[BreakableBody2D.EnvironmentLayer]) -> ImpulseBuilder:
		self._affected_environment_layers = value
		return self
	
	
	## Sets the applied impulse for both detected bodies and players.[br]
	## [br]
	## The used [Callable] [b]must[/b] meet two conditions:[br]
	## - The function's first parameter must be of type [PhysicsBody2D].[br]
	## - When inserted as this function's paramater, use [method Callable.bindv]
	## to give context to the Callable's 2nd+ paramater, if applicable.[br]
	## [br]
	## For example, when the [Callable] you wish to use has the function declaration
	## of 
	## [code]_push(physics_body: PhysicsBody2D, executor_player: Player, direction: Vector2)[/code],
	## you should use this function as so: 
	## [code]applied_body_impulse(_push.bindv([executor_player, direction]))[/code][br]
	## [br]
	## By default, no impulse is applied.
	func applied_impulse(value: Callable) -> ImpulseBuilder:
		self._applied_impulse = value
		return self
	
	
	## Sets the applied impulse for detected bodies.[br]
	## [br]
	## The used [Callable] [b]must[/b] meet two conditions:[br]
	## - The function's first parameter must be of type [PhysicsBody2D].[br]
	## - When inserted as this function's paramater, use [method Callable.bindv]
	## to give context to the Callable's 2nd+ paramater, if applicable.[br]
	## [br]
	## For example, when the [Callable] you wish to use has the function declaration
	## of 
	## [code]_push(physics_body: PhysicsBody2D, executor_player: Player, direction: Vector2)[/code],
	## you should use this function as so: 
	## [code]applied_body_impulse(_push.bindv([executor_player, direction]))[/code][br]
	## [br]
	## By default, no impulse is applied.
	func applied_body_impulse(value: Callable) -> ImpulseBuilder:
		self._applied_body_impulse = value
		return self
	
	
	## Sets the applied impulse for detected players.[br]
	## [br]
	## The used [Callable] [b]must[/b] meet two conditions:[br]
	## - The function's first parameter must be of type [PhysicsBody2D].[br]
	## - When inserted as this function's paramater, use [method Callable.bindv]
	## to give context to the Callable's 2nd+ paramater, if applicable.[br]
	## [br]
	## For example, when the [Callable] you wish to use has the function declaration
	## of 
	## [code]_push(physics_body: PhysicsBody2D, executor_player: Player, direction: Vector2)[/code],
	## you should use this function as so: 
	## [code]applied_body_impulse(_push.bindv([executor_player, direction]))[/code][br]
	## [br]
	## By default, no impulse is applied.
	func applied_player_impulse(value: Callable) -> ImpulseBuilder:
		self._applied_player_impulse = value
		return self
	
	
	## Sets what bodies to exclude from the impulse's collision detection.[br]
	## [br]
	## By default, no body exclusions are defined.
	func excluded_bodies(value: Array[PhysicsBody2D]) -> ImpulseBuilder:
		self._excluded_bodies = value
		return self
	
	
	## Sets what players to exclude from the impulse's collision detection.[br]
	## [br]
	## By default, no player exclusions are defined.
	func excluded_players(value: Array[Player]) -> ImpulseBuilder:
		self._excluded_players = value
		return self
	
	
	## Sets the time in which [PhysicsManager] takes to release the used collision
	## channel. Useful for debugging purposes, but otherwise can be ignore.[br]
	## [br]
	## By default, cleanup time is 1.0s.
	func cleanup_time(value: float) -> ImpulseBuilder:
		self._cleanup_time = value
		return self
	
	
	## Executes an impulse event on the server based off of the settings of the 
	## corresponding [ImpulseBuilder].
	func execute():
		if not PhysicsManager.multiplayer.is_server():
			push_warning("You are executing an Impul`seBuilder on a non-server ",\
				"client. This is not intended, so be careful!")
		
		
		var collision_channel = PhysicsManager.get_collision_channel(_collision_polygon)
		BreakablePhysicsUtil.set_environment_mask_to_all(collision_channel)
		await Engine.get_main_loop().physics_frame
		print(collision_channel.get_overlapping_bodies())
