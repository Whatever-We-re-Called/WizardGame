extends Node

var disasters = {}
var disaster_nodes

var current_disaster: Node
var disaster_area: Rect2

func get_disaster_resource(disaster_type: DisasterEnum) -> DisasterResource:
	if disasters.has(disaster_type):
		return disasters[disaster_type]
	return null


func set_current_disaster(disaster_type: DisasterEnum):
	if multiplayer.is_server():
		_set_current_disaster.rpc(disaster_type)
	
	
func set_disaster_area(disaster_area):
	if multiplayer.is_server():
		self.disaster_area = PolygonUtil.get_rect_from_polygon(disaster_area)
	
	
@rpc("any_peer", "call_local")
func _set_current_disaster(disaster_type: DisasterEnum):
	if current_disaster != null:
		remove_child(current_disaster)
	
	if disaster_type != null:
		var node = Node.new()
		node.name = DisasterEnum.find_key(disaster_type)
		node.script = get_disaster_resource(disaster_type).script_file
		current_disaster = node
		add_child(node)


func _ready() -> void:
	_load_disaster_resources()
	
	disaster_nodes = Node.new()
	add_child(disaster_nodes)
	
	
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
					disasters[resource.enum_type] = resource
		file_name = dir.get_next()
	dir.list_dir_end()
	
	
enum DisasterEnum {
	STORM,
	EARTHQUAKE
}


enum Severity {
	ONE,
	TWO,
	THREE,
	FOUR,
	FIVE
}
