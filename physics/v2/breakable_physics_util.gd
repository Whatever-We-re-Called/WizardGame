class_name BreakablePhysicsUtil


static func set_environment_mask_to_all(node: Node):
	for i in range(4):
		node.set_collision_mask_value(i + 1, true)


static func place_onto_environment_layer(node: Node, layer: BreakableBody2D.EnvironmentLayer, adjust_z_index: bool):
	node.set_collision_layer_value(1, false)
	node.set_collision_layer_value(2, layer == BreakableBody2D.EnvironmentLayer.FRONT)
	node.set_collision_layer_value(3, layer == BreakableBody2D.EnvironmentLayer.BASE)
	node.set_collision_layer_value(4, layer == BreakableBody2D.EnvironmentLayer.BACK)
	node.set_collision_mask_value(1, true)
	node.set_collision_mask_value(2, layer == BreakableBody2D.EnvironmentLayer.FRONT)
	node.set_collision_mask_value(3, layer == BreakableBody2D.EnvironmentLayer.BASE)
	node.set_collision_mask_value(4, layer == BreakableBody2D.EnvironmentLayer.BACK)
	
	if adjust_z_index == true:
		match layer:
			FragileBodyData.EnvironmentLayer.FRONT:
				node.z_index = 1
			FragileBodyData.EnvironmentLayer.BASE:
				node.z_index = 0
			FragileBodyData.EnvironmentLayer.BACK:
				node.z_index = -1


# The only caveat to using the builder design pattern is that
# variables and functions can not share the same name, so some
# variables are named a bit weirdly, in order to prioritize function
# names.
## Handy utility class for easily and cleanly building impulse events with
## consideration for our custom physics system.
class ImpulseBuilder:
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
	## - The first parameter must be of type [PhysicsBody2D].[br]
	## - When inserted as this function's paramater, use [method Callable.bindv]
	## to give context to the Callable's 2nd+ paramater.[br]
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
	## - The first parameter must be of type [PhysicsBody2D].[br]
	## - When inserted as this function's paramater, use [method Callable.bindv]
	## to give context to the Callable's 2nd+ paramater.[br]
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
	## - The first parameter must be of type [PhysicsBody2D].[br]
	## - When inserted as this function's paramater, use [method Callable.bindv]
	## to give context to the Callable's 2nd+ paramater.[br]
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
		pass
