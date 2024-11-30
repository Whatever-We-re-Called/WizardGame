class_name AbilityExecution extends Node2D

var ability: Ability
var type: Abilities.Type
var player: Player
var slot: int
var level: int

var cooldown_timer: SceneTreeTimer

func setup(ability: Ability, type: Abilities.Type, player: Player, slot: int):
	self.ability = ability
	self.type = type
	self.player = player
	self.slot = slot


func process(delta: float) -> void:
	if not player.can_use_abilities:
		return
	
	if _is_cooldown_automatically_managed() and _is_on_cooldown():
		return
	
	var input_action: String
	match (slot):
		0: input_action = player.im.use_ability_1
		1: input_action = player.im.use_ability_2
		2: input_action = player.im.use_ability_3
		
	if Input.is_action_just_pressed(input_action):
		if _on_button_down() and _is_cooldown_automatically_managed():
			_start_cooldown()
	if Input.is_action_just_released(input_action):
		if _on_button_up() and _is_cooldown_automatically_managed():
			_start_cooldown()


func _is_cooldown_automatically_managed() -> bool:
	return true


func _on_button_down() -> bool:
	return false


func _on_button_up():
	return true


func _is_on_cooldown() -> bool:
	return cooldown_timer != null and cooldown_timer.time_left > 0.0


func _start_cooldown():
	cooldown_timer = get_tree().create_timer(ability.cooldown)
	
	
func _cleanup():
	pass
	
	
func get_level():
	return level # TODO - perks
