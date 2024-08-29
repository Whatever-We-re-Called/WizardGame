class_name PhysicsUtil

enum EnvironmentLayer { FRONT, BASE, BACK }


static func set_environment_mask_to_all(node: Node):
	for i in range(4):
		node.set_collision_mask_value(i + 1, true)


static func place_onto_environment_layer(node: Node, layer: EnvironmentLayer, adjust_z_index: bool):
	node.set_collision_layer_value(1, false)
	node.set_collision_layer_value(2, layer == EnvironmentLayer.FRONT)
	node.set_collision_layer_value(3, layer == EnvironmentLayer.BASE)
	node.set_collision_layer_value(4, layer == EnvironmentLayer.BACK)
	node.set_collision_mask_value(1, true)
	node.set_collision_mask_value(2, layer == EnvironmentLayer.FRONT)
	node.set_collision_mask_value(3, layer == EnvironmentLayer.BASE)
	node.set_collision_mask_value(4, layer == EnvironmentLayer.BACK)
	
	if adjust_z_index == true:
		match layer:
			FragileBodyData.EnvironmentLayer.FRONT:
				node.z_index = 1
			FragileBodyData.EnvironmentLayer.BASE:
				node.z_index = 0
			FragileBodyData.EnvironmentLayer.BACK:
				node.z_index = -1
