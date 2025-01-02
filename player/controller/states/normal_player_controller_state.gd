extends PlayerControllerState



func _handle_physics_process(delta: float):
	controller.handle_abilities(delta)
	controller.gravity_component.handle_gravity(player, delta)
	controller.movement_component._handle_horizontal_movement(
		player, controller.physics_frame_input.input_direction.x
	)
	
	player.move_and_slide()
