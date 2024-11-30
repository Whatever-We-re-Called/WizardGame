extends Node
class_name PlayerController

signal paused

@onready var player: CharacterBody2D = $".."

@export_category("Jump & Gravity")
@export var jump_velocity: float

@export var coyote_time: float
var coyote_timer: Timer
var was_on_floor: bool

@export var jump_buffer_time: float
var jump_buffer: Timer

@export var gravity_scale: float
const GRAVITY: float = 9.81

@export_category("Friction & Acceleration")
@export var movement_speed: float
@export var ground_acceleration: float
@export var ground_friction: float
@export var ground_slide_friction: float
@export var air_acceleration: float
@export var air_friction: float

var freeze_input: bool = false
var previous_input_direction: Vector2
var prevent_jump: bool = false


func _ready():
	set_multiplayer_authority(player.peer_id)
	
	self.coyote_timer = Timer.new()
	self.coyote_timer.wait_time = coyote_time
	self.coyote_timer.one_shot = true
	add_child(coyote_timer)
	
	self.jump_buffer = Timer.new()
	self.jump_buffer.wait_time = jump_buffer_time
	self.jump_buffer.one_shot = true
	add_child(jump_buffer)


func _process(delta: float) -> void:
	if not SessionManager.is_playing_local() and not is_multiplayer_authority():
		return
	
	_handle_pause()


func _handle_pause():
	if Input.is_action_just_pressed(player.im.pause):
		paused.emit()


func handle_pre_physics(delta):
	if freeze_input == false:
		was_on_floor = player.is_on_floor()


func handle_physics(delta):
	_handle_ui()
	_handle_gravity(delta)
	
	if freeze_input == false:
		_handle_jump()
		_handle_wasd(delta)
		_handle_abilities(delta)
		
		var input_direction = _get_input_direction()
		if input_direction != Vector2.ZERO:
			previous_input_direction = input_direction
	else:
		_handle_wasd(delta, true)
	
	player.move_and_slide()


func handle_post_physics(delta):
	if freeze_input == false:
		if was_on_floor and not player.is_on_floor():
			coyote_timer.start()


func _handle_ui():
	if Input.is_action_just_pressed(player.im.change_abilities):
		player.change_abilities_ui.toggle()


func _handle_gravity(delta):
	if not player.is_on_floor():
		player.velocity.y += GRAVITY * delta * gravity_scale


func _handle_wasd(delta: float, ignore_input: bool = false):
	var input_direction: Vector2
	if ignore_input == false:
		input_direction = _get_input_direction()
	
		if (input_direction.x > 0 and player.velocity.x > 0) or (input_direction.x < 0 and player.velocity.x < 0):
			previous_input_direction = input_direction
	else:
		input_direction = Vector2.ZERO
	
	if player.is_on_floor():
		_handle_ground_horizontal_movement(input_direction, delta)
	else:
		_handle_air_horizontal_movement(input_direction, delta)
	
	#if input_direction != Vector2.ZERO:
		#player.sprite_2d.flip_h = input_direction.x < 0


# It's usually a good idea to seperate floor and air movement
# for fine-tuning game feel.
func _handle_ground_horizontal_movement(input_direction: Vector2, delta: float):
	if input_direction != Vector2.ZERO:
		if input_direction != previous_input_direction and player.is_on_floor():
			previous_input_direction = input_direction
			player.velocity.x = move_toward(player.velocity.x, 0.0, ground_slide_friction * delta)
		else:
			player.velocity.x = move_toward(player.velocity.x, input_direction.x * movement_speed, ground_acceleration * delta)
	else:
		player.velocity.x = move_toward(player.velocity.x, 0.0, ground_friction * delta)


func _handle_air_horizontal_movement(input_direction: Vector2, delta: float):
	if input_direction != Vector2.ZERO:
		player.velocity.x = move_toward(player.velocity.x, input_direction.x * movement_speed, air_acceleration * delta)
	else:
		player.velocity.x = move_toward(player.velocity.x, 0.0, air_friction * delta)


func _handle_jump():
	if prevent_jump == true: return
	
	if Input.is_action_just_pressed(player.im.jump):
		jump_buffer.start()
	
	if (player.is_on_floor() or not coyote_timer.is_stopped()) and not jump_buffer.is_stopped():
		player.velocity.y = jump_velocity
		jump_buffer.stop()
		coyote_timer.stop()


func _handle_abilities(delta):
	for ability in player.abilities:
		ability.process(delta)


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


func _get_input_direction() -> Vector2:
	return Input.get_vector(player.im.move_left, player.im.move_right, player.im.move_up, player.im.move_down).normalized()


func get_pointer_direction() -> Vector2:
	match player.im.get_device_type():
		DeviceInputMap.DeviceType.KEYBOARD_MOUSE:
			return player.get_center_global_position().direction_to(player.get_global_mouse_position()).normalized()
		DeviceInputMap.DeviceType.CONTROLLER:
			return player.get_direction()
		_:
			return Vector2.ZERO
