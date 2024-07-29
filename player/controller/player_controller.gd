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

@export var gravity_jump_time: float
var gravity_jump_timer: Timer
@export var gravity_scale: float
const GRAVITY: float = 9.81

@export_category("Friction & Acceleration")
@export var movement_speed: float
@export var ground_acceleration: float
@export var ground_friction: float
@export var air_acceleration: float
@export var air_friction: float


func _ready():
	self.coyote_timer = Timer.new()
	self.coyote_timer.wait_time = coyote_time
	self.coyote_timer.one_shot = true
	add_child(coyote_timer)
	
	self.jump_buffer = Timer.new()
	self.jump_buffer.wait_time = jump_buffer_time
	self.jump_buffer.one_shot = true
	add_child(jump_buffer)
	
	self.gravity_jump_timer = Timer.new()
	self.gravity_jump_timer.wait_time = gravity_jump_time
	self.gravity_jump_timer.one_shot = true
	add_child(gravity_jump_timer)
	
	
func handle_pre_physics(delta):
	was_on_floor = player.is_on_floor()
	
	
func handle_physics(delta):
	_handle_gravity(delta)
	_handle_jump()
	_handle_wasd(delta)
	_handle_abilities()
	_handle_debug()
	
	
func handle_post_physics(delta):
	if was_on_floor and not player.is_on_floor():
		coyote_timer.start()
	
	
func _handle_gravity(delta):
	if not player.is_on_floor() and gravity_jump_timer.is_stopped():
		player.velocity.y += GRAVITY * delta * gravity_scale
	
	
func _handle_wasd(delta):
	if player.is_on_floor():
		_handle_horizontal_movement(movement_speed, ground_acceleration, ground_friction, delta)
	else:
		_handle_horizontal_movement(movement_speed, air_acceleration, air_friction, delta)
	
	player.move_and_slide()
	
	
func _handle_horizontal_movement(speed: float, acceleration: float, friction: float, delta: float):
	var input_direction = Input.get_vector(player.im.move_left, player.im.move_right, player.im.move_up, player.im.move_down)
	
	if input_direction != Vector2.ZERO:
		player.velocity.x = move_toward(player.velocity.x, input_direction.x * speed, acceleration * delta)
		#player.velocity.y = move_toward(player.velocity.y, input_direction.y * speed, acceleration * delta)
	else:
		player.velocity.x = move_toward(player.velocity.x, 0.0, friction * delta)
		#player.velocity.y = move_toward(player.velocity.y, 0.0, friction * delta)
	
	
func _handle_jump():
	if Input.is_action_just_pressed(player.im.jump):
		jump_buffer.start()
		
	if (player.is_on_floor() or not coyote_timer.is_stopped()) and not jump_buffer.is_stopped():
		player.velocity.y = jump_velocity
		jump_buffer.stop()
		coyote_timer.stop()
		gravity_jump_timer.start()


func _handle_abilities():
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
		get_tree().reload_current_scene()
