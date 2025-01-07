extends PlayerControllerState



func _handle_physics_process(delta: float):
	controller.handle_abilities(delta)
	controller.movement_component.handle_horizontal_movement(player, player.controller.physics_frame_input.input_direction.x)
	controller.jump_component.handle_jump(player, Input.is_action_just_pressed(player.im.jump), Input.is_action_just_released(player.im.jump))
	
	controller.animation_component.handle_movement_animation.rpc(player.get_path(), player.controller.physics_frame_input.input_direction.x)
	
	controller.gravity_component.handle_gravity(player, delta)
	player.move_and_slide()
