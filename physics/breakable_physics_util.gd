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
			BreakableBody2D.EnvironmentLayer.FRONT:
				node.z_index = 1
			BreakableBody2D.EnvironmentLayer.BASE:
				node.z_index = 0
			BreakableBody2D.EnvironmentLayer.BACK:
				node.z_index = -1
