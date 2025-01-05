extends PlayerControllerState



func _handle_physics_process(delta: float):
	var move_direction = player.controller.physics_frame_input.input_direction.x
	var is_jump_just_pressed = controller.physics_frame_input.is_jump_just_pressed
	
	controller.handle_abilities(delta)
	controller.gravity_component.handle_gravity(player, delta)
	controller.movement_component.handle_horizontal_movement(player, move_direction)
	controller.jump_component.handle_jump(player, is_jump_just_pressed)
	
	controller.animation_component.handle_movement_animation.rpc(player.get_path(), move_direction)
	
	player.move_and_slide()
