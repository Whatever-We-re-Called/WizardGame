class_name AbilityExecution extends Node2D

var ability: Ability
var cooldown_timer: SceneTreeTimer

func setup(ability: Ability):
	self.ability = ability


func _handle_input(player: Player, button_input: String):
	pass


func get_executor_player() -> Player:
	# TODO Improve this. Will require a better session/game handling
	# system, I think. This works for now.
	return get_parent().get_parent()


func is_on_cooldown() -> bool:
	if cooldown_timer != null and cooldown_timer.time_left > 0.0:
		return true
	else:
		return false


func start_cooldown():
	cooldown_timer = get_tree().create_timer(ability.cooldown)
