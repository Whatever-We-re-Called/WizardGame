extends PlayerControllerState

@onready var gravity_component = $GravityControllerComponent
@onready var movement_component = $MovementControllerComponent
@onready var jump_component = $JumpControllerComponent
@onready var spells_component = $SpellsControllerComponent

var move_direction: float
var is_jump_just_pressed: bool
var is_jump_just_released: bool


func _handle_process(delta: float):
	_update_input_variables()
	_handle_animations()
	
	if Input.is_action_just_pressed(player.im.dive) and not player.daze.is_dazed():
		controller.transition_to_state("dive")


func _handle_physics_process(delta: float):
	spells_component.execute_spell(controller.get_selected_spells_execution(), delta)
	
	movement_component.handle_horizontal_movement(player, move_direction)
	jump_component.handle_jump(player, is_jump_just_pressed, is_jump_just_released)
	
	gravity_component.handle_gravity(player, delta)
	player.move_and_slide()


func _update_input_variables():
	move_direction = Input.get_axis(player.im.move_left, player.im.move_right)
	is_jump_just_pressed = Input.is_action_just_pressed(player.im.jump)
	is_jump_just_released = Input.is_action_just_released(player.im.jump)


func _handle_animations():
	var player_node_path = player.get_path()
	
	_handle_movement_animation.rpc(player_node_path, move_direction)


@rpc("any_peer", "call_local", "reliable")
func _handle_movement_animation(player_node_path: NodePath, move_direction: float):
	# TODO
	_handle_horizontal_flip(get_node(player_node_path), move_direction)


func _handle_horizontal_flip(player: Player, move_direction: float):
	if move_direction != 0:
		player.sprite.scale.x = 1 if move_direction > 0 else -1
