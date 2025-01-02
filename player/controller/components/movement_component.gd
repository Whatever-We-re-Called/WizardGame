class_name MovementComponent extends Node

@export var speed: float


func _handle_horizontal_movement(body: CharacterBody2D, direction: float):
	body.velocity.x = speed * direction
