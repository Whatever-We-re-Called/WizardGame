class_name DebugMovementLines extends Line2D

@export var max_points: int = 250

@onready var tracking_object = get_parent()

var tracked_points: Array[Vector2]


func _ready():
	var node = Node.new()
	add_sibling.call_deferred(node)
	reparent.call_deferred(node)
	
	await get_tree().process_frame
	global_position = Vector2.ZERO


func _process(delta: float):
	tracked_points.append(tracking_object.global_position)
	
	if tracked_points.size() > max_points:
		tracked_points.remove_at(0)
	
	# For some reason, the "points" property can only be edited
	# like this? Typical array methods do not work.
	points = tracked_points
