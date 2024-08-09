extends Node
class_name PlayerController

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

var previous_input_direction: Vector2


func _ready():
	self.coyote_timer = Timer.new()
	self.coyote_timer.wait_time = coyote_time
	self.coyote_timer.one_shot = true
	add_child(coyote_timer)
	
	self.jump_buffer = Timer.new()
	self.jump_buffer.wait_time = jump_buffer_time
	self.jump_buffer.one_shot = true
	add_child(jump_buffer)


func handle_pre_physics(delta):
	was_on_floor = player.is_on_floor()


func handle_physics(delta):
	_handle_gravity(delta)
	_handle_jump()
	_handle_wasd(delta)
	_handle_abilities()
	_handle_debug()
	
	player.move_and_slide()
	
	var input_direction = _get_input_direction()
	if input_direction != Vector2.ZERO:
		player.last_input_direction = input_direction


func handle_post_physics(delta):
	if was_on_floor and not player.is_on_floor():
		coyote_timer.start()
	
	
func _handle_gravity(delta):
	if not player.is_on_floor():
		player.velocity.y += GRAVITY * delta * gravity_scale


func _handle_wasd(delta):
	var input_direction = _get_input_direction()
	
	if (input_direction.x > 0 and player.velocity.x > 0) or (input_direction.x < 0 and player.velocity.x < 0):
		previous_input_direction = input_direction
	
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
	if Input.is_action_just_pressed(player.im.jump):
		jump_buffer.start()
	
	if (player.is_on_floor() or not coyote_timer.is_stopped()) and not jump_buffer.is_stopped():
		player.velocity.y = jump_velocity
		jump_buffer.stop()
		coyote_timer.stop()


func _handle_abilities():
	if not player.can_use_abilities: return
	
	var ability_input_strings = [
		player.im.use_ability_1,
		player.im.use_ability_2,
		player.im.use_ability_3
	]
	
	for i in range(3):
		var ability_node = player.ability_nodes.get_child(i)
		var ability_input_string = ability_input_strings[i]
		if ability_node.get_script() != null:
			ability_node._handle_input(player, ability_input_string)


func _handle_debug():
	if Input.is_action_just_pressed(player.im.debug_1):
		player.received_debug_input.emit(1)
	if Input.is_action_just_pressed(player.im.debug_2):
		player.received_debug_input.emit(2)
	if Input.is_action_just_pressed(player.im.debug_3):
		player.received_debug_input.emit(3)
	if Input.is_action_just_pressed(player.im.debug_4):
		if player.change_abilities_panel.visible:
			player.change_abilities_panel.visible = false
			player.can_use_abilities = true
		else:
			player.change_abilities_panel.visible = true
			player.can_use_abilities = false


func _get_input_direction() -> Vector2:
	return Input.get_vector(player.im.move_left, player.im.move_right, player.im.move_up, player.im.move_down).normalized()
