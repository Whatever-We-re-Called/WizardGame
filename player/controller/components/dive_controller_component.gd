class_name DiveControllerComponent extends Node

@export var dive_strength: Vector2


func handle_dive(body: CharacterBody2D, move_direction: float):
	body.velocity.x /= 4.0
	body.velocity.x += move_direction * dive_strength.x
	
	body.velocity.y = dive_strength.y
