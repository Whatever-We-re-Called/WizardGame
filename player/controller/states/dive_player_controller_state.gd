extends PlayerControllerState

@export var dive_daze: float

@onready var gravity_component = $GravityControllerComponent
@onready var dive_component = $DiveControllerComponent
@onready var movement_component = $MovementControllerComponent
@onready var spells_component = $SpellsControllerComponent


func _enter():
	dive_component.handle_dive(player, controller.get_last_move_direction())
	player.daze.add_daze(dive_daze)


func _handle_process(delta: float):
	if player.is_on_floor():
		controller.transition_to_state("normal")


func _handle_physics_process(delta: float):
	spells_component.execute_spell(controller.get_selected_spells_execution(), delta)
	
	movement_component.handle_horizontal_movement(player, 0)
	
	gravity_component.handle_gravity(player, delta)
	player.move_and_slide()
