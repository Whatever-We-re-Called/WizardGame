extends PlayerControllerState

@onready var gravity_component = $GravityControllerComponent
@onready var dive_component = $DiveControllerComponent
@onready var movement_component = $MovementControllerComponent
@onready var spells_component = $SpellsControllerComponent

var move_direction: float
var is_jump_just_pressed: bool
var is_jump_just_released: bool


func _enter():
	_update_input_variables()
	dive_component.handle_dive(player, controller.get_last_move_direction())


func _handle_process(delta: float):
	_update_input_variables()
	
	if player.is_on_floor():
		controller.transition_to_state("normal")


func _handle_physics_process(delta: float):
	spells_component.execute_spell(controller.get_selected_spells_execution(), delta)
	
	movement_component.handle_horizontal_movement(player, 0)
	
	gravity_component.handle_gravity(player, delta)
	player.move_and_slide()


func _update_input_variables():
	move_direction = Input.get_axis(player.im.move_left, player.im.move_right)
	is_jump_just_pressed = Input.is_action_just_pressed(player.im.jump)
	is_jump_just_released = Input.is_action_just_released(player.im.jump)
