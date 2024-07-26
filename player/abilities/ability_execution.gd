class_name AbilityExecution

class AbilityExecutionData:
	var ability: Ability
	var executor_player: Player

const WIND_GUST_AREA = preload("res://player/abilities/scenes/wind_gust_area.tscn")


static func try_to_execute(ability: Ability, executor_player: Player):
	var ability_execution_data = AbilityExecutionData.new()
	ability_execution_data.ability = ability
	ability_execution_data.executor_player = executor_player
	
	_execute(ability_execution_data)


static func _execute(ability_execution_data: AbilityExecutionData):
	var regex = RegEx.new()
	regex.compile("[a-z,A-Z,0-9,_]*.tres")
	var file_name = regex.search(ability_execution_data.ability.resource_path).get_string()
	var execution_function_name = "_" + file_name.substr(0, file_name.length() - 5)
	
	var execute_callable = Callable(AbilityExecution, execution_function_name)
	execute_callable.call(ability_execution_data)


static func _wind_gust(ability_execution_data: AbilityExecutionData):
	var executor_player = ability_execution_data.executor_player
	
	var direction = executor_player.get_center_global_position().direction_to(executor_player.get_global_mouse_position())
	direction = direction.normalized()
	
	var wind_gust_area = WIND_GUST_AREA.instantiate()
	wind_gust_area.setup(direction, executor_player, 1000.0)
	executor_player.get_tree().root.add_child(wind_gust_area)
