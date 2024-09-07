extends Node

@export var starting_count: int = 100
@export var min_free_ratio: float = 0.2

var current_count: int
var free_channels: Array[Area2D]

const PHYSICS_FRAMES_UNTIL_CREATION: int = 2


func _ready():
	self.current_count = starting_count
	_init_channels()


func _init_channels():
	for i in range(starting_count):
		_add_channel()


func get_channel(collision_polygon: PackedVector2Array) -> Area2D:
	for child in get_children():
		if child is Area2D and free_channels.has(child):
			free_channels.erase(child)
			(child.get_child(0) as CollisionPolygon2D).polygon = collision_polygon
			return child
	
	push_error("Could not find a free physics collision channel to give you. ",\
		"Most likely, you are requesting too many channels in too short of a time ",\
		"duration; PhysicsManager does handle creating new channels when space is ",\
		"low, but it takes ", PHYSICS_FRAMES_UNTIL_CREATION, " physics frames for ",\
		"those channels to become free after initilization.")
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
	
	for i in range(PHYSICS_FRAMES_UNTIL_CREATION):
		await get_tree().physics_frame
	
	free_channels.append(area_2d)


func _update_channel_count():
	var ratio = free_channels.size() / get_children().size()
	if ratio < min_free_ratio:
		_add_channel()


func reset_channels():
	for child in get_children():
		child.queue_free()
	free_channels.clear()
	
	_init_channels()
