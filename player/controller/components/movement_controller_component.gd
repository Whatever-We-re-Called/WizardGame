extends Node

@export var speed: float


func handle_horizontal_movement(body: CharacterBody2D, move_direction: float):
	body.velocity.x = speed * move_direction
	
	_handle_horizontal_flip(body, move_direction)


func _handle_horizontal_flip(body: CharacterBody2D, move_direction: float):
	if move_direction != 0:
		body.sprite.scale.x = 1 if move_direction > 0 else -1
