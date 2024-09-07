extends Node

@export var starting_count: int = 100
@export var min_free_ratio: float = 0.2

var current_count: int
var free_channels: Array[Area2D]


func _ready():
	self.current_count = starting_count
	
	for i in range(starting_count):
		_add_channel()


func get_channel() -> Area2D:
	
	
	for child in get_children():
		if child is Area2D and not free_channels.has(child):
			free_channels.erase(child)
			return child
	return null


func release_channel(area: Area2D):
	if not free_channels.has(area):
		free_channels.append(area)
		for child in area.get_children():
			if child is CollisionPolygon2D:
				child.polygon = []



func _add_channel():
	var area_2d = Area2D.new()
	var collision_polygon = CollisionPolygon2D.new()
	area_2d.add_child(collision_polygon)
	add_child(area_2d)
	free_channels.append(area_2d)


func _remove_channel():
	pass


func _update_channel_count():
	var ratio = free_channels.size() / get_children().size()
	if ratio < min_free_ratio:
		pass
