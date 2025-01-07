extends Node

@export var climb_gravity: float
@export var fall_gravity: float
@export var terminal_gravity: float

var is_falling: bool = false
var prevent_jump: bool = false


func handle_gravity(body: CharacterBody2D, delta: float):
	_apply_gravity(body, delta)
	
	is_falling = body.velocity.y > 0 and body.is_on_floor() == false


func _apply_gravity(body: CharacterBody2D, delta: float):
	if body.is_on_floor() == false:
		var new_y_velocity: float
		if is_falling == true:
			new_y_velocity = body.velocity.y + fall_gravity * delta
		else:
			new_y_velocity = body.velocity.y + climb_gravity * delta
		new_y_velocity = min(new_y_velocity, terminal_gravity)
		
		body.velocity.y = new_y_velocity
