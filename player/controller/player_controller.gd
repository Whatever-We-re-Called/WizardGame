extends Node
class_name PlayerController

signal paused

@export var states_node: Node

@onready var player: Player = get_parent()
@onready var gravity_component: GravityComponent = $GravityComponent
@onready var movement_component: MovementComponent = $MovementComponent

var current_state: PlayerControllerState
var states: Dictionary
var freeze_input: bool = false
var pre_physics_frame_input: FrameInput
var physics_frame_input: FrameInput
var post_physics_frame_input: FrameInput


func _ready():
	set_multiplayer_authority(player.peer_id)
	
	_setup_states()
	transition_to_state("normal")


func _setup_states():
	for child in states_node.get_children():
		if child is PlayerControllerState:
			states[child.name.to_lower()] = child
			child.setup(player)


func transition_to_state(new_state_name: String, skip_enter: bool = false, skip_exit: bool = false):
	var new_state = states.get(new_state_name.to_lower())
	if new_state == null:
		push_error("Invalid state: ", new_state_name)
		return
	
	if current_state != null and skip_exit == false:
		current_state._exit()
	
	if skip_enter == false:
		new_state._enter()
	
	current_state = new_state


func _process(delta: float) -> void:
	if not SessionManager.is_playing_local() and not is_multiplayer_authority():
		return
	
	current_state._handle_process(delta)
	_handle_pause()
	_handle_ui()


func handle_pre_physics(delta):
	if freeze_input == false:
		pre_physics_frame_input = _get_frame_input()
		current_state._handle_pre_physics_process(delta)


func handle_physics(delta):
	if freeze_input == false:
		physics_frame_input = _get_frame_input()
		current_state._handle_physics_process(delta)


func handle_post_physics(delta):
	if freeze_input == false:
		post_physics_frame_input = _get_frame_input()
		current_state._handle_post_physics_process(delta)


func _get_frame_input() -> FrameInput:
	var frame_input = FrameInput.new()
	frame_input.is_jump_just_pressed = Input.is_action_just_pressed(player.im.jump)
	frame_input.is_jump_pressed = Input.is_action_pressed(player.im.jump)
	frame_input.input_direction = Input.get_vector(
		player.im.move_left,
		player.im.move_right, 
		player.im.move_up,
		player.im.move_down
	).normalized()
	return frame_input


class FrameInput:
	var is_jump_just_pressed: bool
	var is_jump_pressed: bool
	var input_direction: Vector2


func _handle_pause():
	if Input.is_action_just_pressed(player.im.pause):
		paused.emit()


func _handle_ui():
	if Input.is_action_just_pressed(player.im.change_abilities):
		player.change_abilities_ui.toggle()


func handle_abilities(delta):
	for spell in player.spell_inventory.equipped_spells:
		spell.process(delta)


func handle_debug_inputs():
	if Input.is_action_just_pressed(player.im.debug_1):
		player.received_debug_input.emit(1)
	if Input.is_action_just_pressed(player.im.debug_2):
		player.received_debug_input.emit(2)
	if Input.is_action_just_pressed(player.im.debug_3):
		player.received_debug_input.emit(3)
	if Input.is_action_just_pressed(player.im.debug_4):
		player.received_debug_input.emit(4)
	if Input.is_action_just_pressed(player.im.debug_tab):
		player.received_debug_input.emit(5)


func get_pointer_direction() -> Vector2:
	match player.im.get_device_type():
		DeviceInputMap.DeviceType.KEYBOARD_MOUSE:
			return player.get_center_global_position().direction_to(player.get_global_mouse_position()).normalized()
		DeviceInputMap.DeviceType.CONTROLLER:
			return player.get_direction()
		_:
			return Vector2.ZERO
