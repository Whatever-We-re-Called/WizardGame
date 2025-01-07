extends Node

@export var jump_strength: float
@export var wall_jump_strength: Vector2
@export var jump_buffer_time: float
@export var coyote_time: float

@onready var jump_buffer_timer = TimerUtil.create_basic_timer(self, jump_buffer_time)
@onready var coyote_timer = TimerUtil.create_basic_timer(self, coyote_time)

var is_going_up: bool = false
var is_jumping: bool = false
var was_on_floor_last_frame: bool = false


func handle_jump(body: CharacterBody2D, wants_to_jump: bool, released_jump: bool):
	if _has_just_landed(body):
		is_jumping = false
	
	if _is_allowed_to_jump(body, wants_to_jump):
		_execute_jump(body)
	
	_try_to_wall_jump(body, wants_to_jump)
	
	_handle_coyote_time(body)
	_handle_jump_buffer(body, wants_to_jump)
	_handle_variable_jump_height(body, released_jump)
	
	is_going_up = body.velocity.y < 0 and not body.is_on_floor()
	was_on_floor_last_frame = body.is_on_floor()


func _has_just_landed(body: CharacterBody2D) -> bool:
	return body.is_on_floor() and not was_on_floor_last_frame and is_jumping


func _is_allowed_to_jump(body: CharacterBody2D, wants_to_jump: bool) -> bool:
	return wants_to_jump and (body.is_on_floor() or not coyote_timer.is_stopped())


func _execute_jump(body: CharacterBody2D):
	is_jumping = true
	body.velocity.y = jump_strength
	
	jump_buffer_timer.stop()
	coyote_timer.stop()


func _try_to_wall_jump(body: CharacterBody2D, wants_to_jump: bool):
	if body.is_on_wall_only() and wants_to_jump:
		var wall_normal = body.get_wall_normal()
		body.velocity = Vector2(
			wall_jump_strength.x * -wall_normal.x,
			wall_jump_strength.y
		)


func _handle_coyote_time(body: CharacterBody2D):
	if _has_just_stepped_off_ledge(body):
		coyote_timer.start()


func _has_just_stepped_off_ledge(body: CharacterBody2D) -> bool:
	return not body.is_on_floor() and was_on_floor_last_frame and not is_jumping


func _handle_jump_buffer(body: CharacterBody2D, wants_to_jump: bool):
	if wants_to_jump and not body.is_on_floor():
		jump_buffer_timer.start()
	
	if body.is_on_floor() and not jump_buffer_timer.is_stopped():
		_execute_jump(body)


func _handle_variable_jump_height(body: CharacterBody2D, released_jump: bool):
	if released_jump and is_going_up:
		body.velocity.y /= 2.0
