extends Node

@onready var collision_channel_manager: Node = $CollisionChannelManager


func get_collision_channel(collision_polygon: PackedVector2Array) -> CollisionChannel:
	var collision_channel = collision_channel_manager.get_channel()
	await collision_channel.update_polygon(collision_polygon)
	return collision_channel


func release_collision_channel(collision_channel: CollisionChannel):
	collision_channel_manager.release_channel(collision_channel)


## Handy utility class for easily and cleanly building impulse events with
## consideration for our custom physics system.
class ImpulseBuilder extends Node:
	var _collision_polygon: PackedVector2Array = []
	var _affected_environment_layers: Array[BreakableBody2D.EnvironmentLayer] = []
	var _applied_impulse: Callable
	var _applied_body_impulse: Callable
	var _applied_player_impulse: Callable
	var _excluded_bodies_from_impulse: Array[PhysicsBody2D] = []
	var _excluded_players_from_impulse: Array[Player] = []
	var _applied_damage_value: int = 0
	var _applied_damage_impulse: Callable
	var _excluded_players_from_damage: Array[Player]
	var _kills_players: bool = false
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
	## - The function's return type must be [Vector2]; the impulse force.[br]
	## - The function's first parameter must be of type or of a type extended 
	## from [PhysicsBody2D].[br]
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
	## - The function's return type must be [Vector2]; the impulse force.[br]
	## - The function's first parameter must be of type or of a type extended 
	## from [PhysicsBody2D].[br]
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
	## - The function's return type must be [Vector2]; the impulse force.[br]
	## - The function's first parameter must be of type or of a type extended 
	## from [PhysicsBody2D].[br]
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
	func excluded_bodies_from_impulse(value: Array[PhysicsBody2D]) -> ImpulseBuilder:
		self._excluded_bodies_from_impulse = value
		return self
	
	
	## Sets what players to exclude from the impulse's collision detection.[br]
	## [br]
	## By default, no player exclusions are defined.
	func excluded_players_from_impulse(value: Array[Player]) -> ImpulseBuilder:
		self._excluded_players_from_impulse = value
		return self
	
	
	## Sets how much damage the impulse does to BreakableBody2Ds.
	## and the impulse that is applied if the body is broken.[br]
	## [br]
	## The used [Callable] [b]must[/b] meet two conditions:[br]
	## - The function's return type must be [Vector2]; the impulse force.[br]
	## - The function's first parameter must be of type or of a type extended 
	## from [PhysicsBody2D].[br]
	## - When inserted as this function's paramater, use [method Callable.bindv]
	## to give context to the Callable's 2nd+ paramater, if applicable.[br]
	## [br]
	## For example, when the [Callable] you wish to use has the function declaration
	## of 
	## [code]_push(physics_body: PhysicsBody2D, executor_player: Player, direction: Vector2)[/code],
	## you should use this function as so: 
	## [code]applied_body_impulse(_push.bindv([executor_player, direction]))[/code][br]
	## [br]
	## By default, no damage or damage impulse is applied, causing bodies
	## to instantly destroy.
	func applied_damage(damage_value: int, damage_impulse: Callable) -> ImpulseBuilder:
		self._applied_damage_value = damage_value
		self._applied_damage_impulse = damage_impulse
		return self
	
	
	## Sets what players to exclude from the damage dealt by the collision.[br]
	## [br]
	## By default, no player exclusions are defined.
	func excluded_players_from_damage(value: Array[Player]) -> ImpulseBuilder:
		self._excluded_players_from_damage = value
		return self
	
	
	## Sets whether or not the collision kills any non-excluded players
	## inside of it.[br]
	## [br]
	## By default, the collision does not kill any players.
	func kills_players(value: bool) -> ImpulseBuilder:
		self._kills_players = value
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
			push_warning("You are executing an ImpulseBuilder on a non-server ",\
				"client. This is not intended, so be careful!")
		
		var collision_channel = await CollisionChannelBuilder.new()\
			.collision_polygon(_collision_polygon)\
			.collision_mask_values(_get_affected_layers_as_mask_values())\
			.claim()
		
		for overlapping_body in collision_channel.get_overlapping_bodies():
			print(overlapping_body)
			if overlapping_body is Player:
				if _kills_players == true:
					if not _excluded_players_from_damage.has(overlapping_body):
						overlapping_body.kill()
				else:
					_try_to_push_player(overlapping_body, collision_channel)
			elif overlapping_body is RigidBody2D:
				if _applied_damage_value > 0 and overlapping_body is BreakableBody2D:
					_damage_body(overlapping_body, collision_channel)
				else:
					_try_to_push_body(overlapping_body, collision_channel)
		
		await PhysicsManager.get_tree().create_timer(_cleanup_time).timeout
		PhysicsManager.release_collision_channel(collision_channel)
	
	
	func _get_affected_layers_as_mask_values() -> Array[int]:
		var result: Array[int]
		
		# Environment layers
		result.append(1)
		for environment_layer in _affected_environment_layers:
			match environment_layer:
				BreakableBody2D.EnvironmentLayer.FRONT:
					result.append(2)
				BreakableBody2D.EnvironmentLayer.BASE:
					result.append(3)
				BreakableBody2D.EnvironmentLayer.BACK:
					result.append(4)
				BreakableBody2D.EnvironmentLayer.ALL:
					result.append_array([2, 3, 4])
		
		# Player layer
		result.append(5)
		
		return result
	
	
	func _try_to_push_player(body: PhysicsBody2D, collision_channel: CollisionChannel):
		if _excluded_players_from_impulse.has(body): return
		
		var impulse: Vector2
		if _applied_player_impulse.is_valid():
			impulse = _applied_player_impulse.call(body)
		elif _applied_impulse.is_valid():
			impulse = _applied_impulse.call(body)
		
		body.velocity = Vector2.ZERO
		body.add_velocity(impulse)
	
	
	func _damage_body(body: PhysicsBody2D, collision_channel: CollisionChannel):
		body.damage_with_collision(
			_applied_damage_value,
			_applied_damage_impulse,
			collision_channel.collision_polygon
		)
	
	
	func _try_to_push_body(body: PhysicsBody2D, collision_channel: CollisionChannel):
		if _excluded_bodies_from_impulse.has(body): return
		
		if body is BreakableBody2D:
			var impulse_callable: Callable
			if _applied_body_impulse.is_valid():
				impulse_callable = _applied_body_impulse
			elif _applied_impulse.is_valid():
				impulse_callable = _applied_impulse
				
			body.break_apart_from_collision(
				collision_channel.collision_polygon,
				impulse_callable
			)
		elif body is RigidBody2D:
			var impulse: Vector2
			if _applied_body_impulse.is_valid():
				impulse = _applied_body_impulse.call(body)
			elif _applied_impulse.is_valid():
				impulse = _applied_impulse.call(body)
			
			body.apply_central_impulse(impulse)


class CollisionChannelBuilder:
	var _collision_polygon: PackedVector2Array = []
	var _collision_layer_values: Array[int] = []
	var _collision_mask_values: Array[int] = []
	
	
	## Sets the polygon used for the collision channel.[br]
	## [br]
	## By default, a polygon with no defined points is used.
	func collision_polygon(value: PackedVector2Array) -> CollisionChannelBuilder:
		self._collision_polygon = value
		return self
	
	
	## Sets the collision layer values used by the collision channel.[br]
	## [br]
	## By default, no collision layer values are defined.
	func collision_layer_values(value: Array[int]) -> CollisionChannelBuilder:
		self._collision_layer_values = value
		return self
	
	
	## Sets the collision mask values used by the collision channel.[br]
	## [br]
	## By default, no collision mask values are defined.
	func collision_mask_values(value: Array[int]) -> CollisionChannelBuilder:
		self._collision_mask_values = value
		return self
	
	
	## Claims a collision channel in [CollisionChannelManager] and gives you it
	## configured with all data defined by the builder. Currently, this does
	## take 1 physics frame to complete, so you must [code]await[/code] and allow
	## the collision channel to properly finish configuring itself.
	func claim() -> CollisionChannel:
		var collision_channel = PhysicsManager.collision_channel_manager.get_channel()
		_update_collision_values(collision_channel)
		await collision_channel.update_polygon(_collision_polygon)
		await Engine.get_main_loop().physics_frame
		
		return collision_channel
	
	
	func _update_collision_values(collision_channel: CollisionChannel):
		collision_channel.set_collision_layer_value(1, false)
		for value in _collision_layer_values:
			collision_channel.set_collision_layer_value(value, true)
		
		collision_channel.set_collision_mask_value(1, false)
		for value in _collision_mask_values:
			collision_channel.set_collision_mask_value(value, true)
