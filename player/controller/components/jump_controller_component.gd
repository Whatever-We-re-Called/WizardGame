extends Node

@export var jump_strength: float

var is_jumping: bool = false


func handle_jump(body: CharacterBody2D, wants_to_jump: bool):
	if wants_to_jump and body.is_on_floor():
		body.velocity.y = jump_strength
	
	is_jumping = body.velocity.y < 0 and not body.is_on_floor()
