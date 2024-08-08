class_name SpawnPoints extends Node2D


func get_random_list_of_spawn_locations(quantity: int, try_to_avoid_duplicates: bool) -> Array[Vector2]:
	var result: Array[Vector2]
	
	randomize()
	var rng = RandomNumberGenerator.new()
	var spawn_locations = _get_list_of_spawn_locations().duplicate()
	while result.size() < quantity:
		var i = randi_range(0, spawn_locations.size() - 1)
		result.append(spawn_locations[i])
		spawn_locations.remove_at(i)
		
		if spawn_locations.size() <= 0:
			spawn_locations = _get_list_of_spawn_locations().duplicate()
	
	return result


func get_random_spawn_location() -> Vector2:
	randomize()
	var rng = RandomNumberGenerator.new()
	var spawn_locations = _get_list_of_spawn_locations()
	return spawn_locations[randi_range(0, spawn_locations.size() - 1)]


func _get_list_of_spawn_locations() -> Array[Vector2]:
	var result: Array[Vector2]
	
	for child in get_children():
		if child is Node2D:
			result.append(child.global_position)
	
	return result
