class_name GravityComponent extends Node

@export var gravity: float

var is_falling: bool = false
var prevent_jump: bool = false


func handle_gravity(body: CharacterBody2D, delta: float):
	if body.is_on_floor() == false:
		# CharacterBody2D.move_and_slide() handles delta, with 
		# the exception of gravity! So its handled here.
		body.velocity.y += gravity * delta
	
	is_falling = body.velocity.y > 0 and body.is_on_floor() == false
