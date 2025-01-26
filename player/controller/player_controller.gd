class_name PlayerController extends Node

signal paused

@onready var player: Player = get_parent()

var current_state: PlayerControllerState
var states: Dictionary
var freeze_input: bool = false
var selected_spell_slot: int = 1
var last_frame_input: FrameInput

class FrameInput:
	var input_direction: Vector2


func _ready():
	set_multiplayer_authority(player.peer_id)
	
	_setup_states()
	transition_to_state("normal")


func _setup_states():
	for child in get_children():
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
	_update_selected_spell_slot()


func handle_pre_physics(delta):
	if freeze_input == false:
		last_frame_input = _create_frame_input()
		current_state._handle_pre_physics_process(delta)


func handle_physics(delta):
	if freeze_input == false:
		last_frame_input = _create_frame_input()
		current_state._handle_physics_process(delta)


func handle_post_physics(delta):
	if freeze_input == false:
		last_frame_input = _create_frame_input()
		current_state._handle_post_physics_process(delta)


func _create_frame_input():
	var frame_input = FrameInput.new()
	frame_input.input_direction = Input.get_vector(
		player.im.move_left, 
		player.im.move_right,
		player.im.move_up,
		player.im.move_down
	).normalized()
	return frame_input


func _handle_pause():
	if Input.is_action_just_pressed(player.im.pause):
		paused.emit()


func _handle_ui():
	if Input.is_action_just_pressed(player.im.change_spells):
		player.change_abilities_ui.toggle()


func get_pointer_direction() -> Vector2:
	match player.im.get_device_type():
		DeviceInputMap.DeviceType.KEYBOARD_MOUSE:
			return player.get_center_global_position().direction_to(player.get_global_mouse_position()).normalized()
		DeviceInputMap.DeviceType.CONTROLLER:
			return last_frame_input.input_direction
		_:
			return Vector2.ZERO


func get_selected_spells_execution() -> SpellExecution:
	return player.spell_inventory.equipped_spells[selected_spell_slot - 1]


func _update_selected_spell_slot():
	if Input.is_action_just_pressed(player.im.select_spell_slot_1):
		selected_spell_slot = 1
	elif Input.is_action_just_pressed(player.im.select_spell_slot_2):
		selected_spell_slot = 2
	elif Input.is_action_just_pressed(player.im.select_spell_slot_3):
		selected_spell_slot = 3
	elif Input.is_action_just_pressed(player.im.select_next_spell_slot):
		_increment_selected_spell_slot(1)
	elif Input.is_action_just_pressed(player.im.select_spell_slot_3):
		_increment_selected_spell_slot(-1)


func _increment_selected_spell_slot(increment_value: int):
	selected_spell_slot = ((selected_spell_slot + increment_value - 1) % 3) + 1
