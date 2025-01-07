extends PlayerControllerState



func _handle_physics_process(delta: float):
	var move_direction = Input.get_axis(player.im.move_left, player.im.move_right)
	var is_jump_just_pressed = Input.is_action_just_pressed(player.im.jump)
	var is_jump_just_released = Input.is_action_just_released(player.im.jump)
	
	controller.handle_abilities(delta)
	controller.movement_component.handle_horizontal_movement(player, move_direction)
	controller.jump_component.handle_jump(player, is_jump_just_pressed, is_jump_just_released)
	
	controller.animation_component.handle_movement_animation.rpc(player.get_path(), move_direction)
	
	controller.gravity_component.handle_gravity(player, delta)
	player.move_and_slide()
