class_name MovementControllerComponent extends Node

@export var speed: float
@export var floor_acceleration_speed: float
@export var floor_deceleration_speed: float
@export var air_acceleration_speed: float
@export var air_deceleration_speed: float


func handle_horizontal_movement(body: CharacterBody2D, move_direction: float):
	var velocity_change_speed = 0.0
	if body.is_on_floor():
		if move_direction != 0:
			velocity_change_speed = floor_acceleration_speed
		else:
			velocity_change_speed = floor_deceleration_speed
	else:
		if move_direction != 0:
			velocity_change_speed = air_acceleration_speed
		else:
			velocity_change_speed = air_deceleration_speed
	
	body.velocity.x = move_toward(body.velocity.x, speed * move_direction, velocity_change_speed)
