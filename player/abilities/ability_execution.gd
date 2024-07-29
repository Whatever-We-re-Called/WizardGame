extends Node

#const WIND_GUST_AREA = preload("res://player/abilities/scenes/wind_gust_area.tscn")

class AbilityExecutionData:
	var ability: Ability
	var executor_player: Player


func try_to_execute(ability: Ability, executor_player: Player):
	var ability_execution_data = AbilityExecutionData.new()
	ability_execution_data.ability = ability
	ability_execution_data.executor_player = executor_player
	
	_execute.rpc_id(1, _deconstruct_ability_execution_data(ability_execution_data))


@rpc("any_peer", "call_local")
func _execute(deconstructed_ability_execution_data: Array):
	var ability_execution_data = _reconstruct_ability_execution_data(deconstructed_ability_execution_data)
	
	var regex = RegEx.new()
	regex.compile("[a-z,A-Z,0-9,_]*.tres")
	var file_name = regex.search(ability_execution_data.ability.resource_path).get_string()
	var execution_function_name = "_" + file_name.substr(0, file_name.length() - 5)
	
	var execute_callable = Callable(AbilityExecution, execution_function_name)
	execute_callable.rpc_id(1, _deconstruct_ability_execution_data(ability_execution_data))


@rpc("any_peer", "call_local")
func _wind_gust(deconstructed_ability_execution_data: Array):
	var ability_execution_data = _reconstruct_ability_execution_data(deconstructed_ability_execution_data)
	var executor_player = ability_execution_data.executor_player
	
	var direction = executor_player.get_center_global_position().direction_to(executor_player.get_global_mouse_position())
	direction = direction.normalized()


func _deconstruct_ability_execution_data(ability_execution_data: AbilityExecutionData) -> Array:
	return [ability_execution_data.ability.resource_path, ability_execution_data.executor_player.get_path()]


func _reconstruct_ability_execution_data(array: Array) -> AbilityExecutionData:
	var result = AbilityExecutionData.new()
	result.ability = load(array[0])
	result.executor_player = get_node(array[1])
	return result
