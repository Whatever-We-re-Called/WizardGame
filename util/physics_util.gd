class_name PhysicsUtil


static func set_environment_mask_to_all(node: Node):
	for i in range(4):
		node.set_collision_mask_value(i + 1, true)
