extends Node

var disasters = {}


func get_disaster_resource(disaster_type: DisasterType) -> Node:
	if disasters.has(disaster_type):
		return disasters[disaster_type]
	return null


func _ready() -> void:
	_load_disaster_resources()
	
	
func _load_disaster_resources(path = "res://disasters"):
	var dir = DirAccess.open(path)
	if not dir:
		print("Failed to open directory: ", path)
		return

	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if file_name == "." or file_name == "..":
			file_name = dir.get_next()
			continue

		var full_path = path + "/" + file_name
		if dir.current_is_dir():
			_load_disaster_resources(full_path)
		else:
			if file_name.ends_with(".tres"):
				var resource = ResourceLoader.load(full_path)
				if resource is DisasterResource:
					disasters[resource.type] = resource
		file_name = dir.get_next()
	dir.list_dir_end()
	
	
enum DisasterType {
	STORM
}


enum DisasterSeverity {
	ONE,
	TWO,
	THREE,
	FOUR,
	FIVE
}
