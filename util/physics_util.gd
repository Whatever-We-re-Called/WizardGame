class_name PhysicsUtil


static func set_environment_collision_masks(node: Node, foreground_interactable: bool, background_interactable: bool):
	node.set_collision_mask_value(2, foreground_interactable)
	node.set_collision_mask_value(3, background_interactable)
