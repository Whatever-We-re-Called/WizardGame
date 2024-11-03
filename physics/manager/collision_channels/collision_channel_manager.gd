class_name CollisionChannelManager extends Node

@export var starting_count: int = 100
@export var min_free_ratio: float = 0.2

var current_count: int
var free_channels: Array[CollisionChannel]


func _ready():
	self.current_count = starting_count
	_init_channels()


func _init_channels():
	for i in range(starting_count):
		_add_channel()


func get_channel() -> CollisionChannel:
	for child in get_children():
		if child is CollisionChannel and free_channels.has(child):
			free_channels.erase(child)
			return child
	
	push_error("Could not find a free physics collision channel to give you. ",\
		"Most likely, you are requesting too many channels in too short of a time ",\
		"duration; PhysicsManager does handle creating new channels when space is ",\
		"low, but it takes ", CollisionChannel.PHYSICS_FRAMES_UNTIL_CREATION,\
		" physics frames for those channels to become free after initilization.")
	return null


func release_channel(collision_channel: CollisionChannel):
	if not free_channels.has(collision_channel):
		free_channels.append(collision_channel)
		collision_channel.reset_polygon()


func _add_channel():
	var collision_channel = await CollisionChannel.new()
	add_child(collision_channel)
	free_channels.append(collision_channel)


func _update_channel_count():
	var ratio = int(free_channels.size() / float(get_children().size()))
	if ratio < min_free_ratio:
		_add_channel()


func reset_channels():
	for child in get_children():
		child.queue_free()
	free_channels.clear()
	
	_init_channels()
