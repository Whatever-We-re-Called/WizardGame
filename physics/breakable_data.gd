class_name BreakableData extends Resource

@export var max_health: float = 10.0
@export var layer: BreakableBody2D.EnvironmentLayer = BreakableBody2D.EnvironmentLayer.BASE
@export_range(0, 200) var number_of_break_points: int = 5


func get_as_dictionary() -> Dictionary:
	var result = {}
	result["max_health"] = max_health
	result["layer"] = layer
	result["number_of_break_points"] = number_of_break_points
	
	return result


static func get_from_dictionary(data_dictionary: Dictionary) -> BreakableData:
	var result = BreakableData.new()
	result.max_health = data_dictionary["max_health"]
	result.layer = data_dictionary["layer"]
	result.number_of_break_points = data_dictionary["number_of_break_points"]
	
	return result
