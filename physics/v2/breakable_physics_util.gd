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
class ImpulseBuilder:
	var _collision_polygon: PackedVector2Array = []
	var _affected_environment_layers: Array[BreakableBody2D.EnvironmentLayer] = []
	var _excluded_players: Array[Player] = []
	var _applied_impulse: Callable
	var _applied_body_impulse: Callable
	var _applied_player_impulse: Callable
	var _cleanup_time: float = 1.0
	
	
	func collision_polygon(value: PackedVector2Array) -> ImpulseBuilder:
		self._collision_polygon = value
		return self
	
	
	func affected_environment_layers(value: Array[BreakableBody2D.EnvironmentLayer]) -> ImpulseBuilder:
		self._affected_environment_layers = value
		return self
	
	
	func excluded_players(value: Array[Player]) -> ImpulseBuilder:
		self._excluded_players = value
		return self
	
	
	func applied_impulse(value: Callable) -> ImpulseBuilder:
		self._applied_impulse = value
		return self
	
	
	func applied_body_impulse(value: Callable) -> ImpulseBuilder:
		self._applied_body_impulse = value
		return self
	
	
	func applied_player_impulse(value: Callable) -> ImpulseBuilder:
		self._applied_player_impulse = value
		return self
	
	
	func cleanup_time(value: float) -> ImpulseBuilder:
		self._cleanup_time = value
		return self
	
	
	func execute():
		pass
