extends Node
class_name Disaster


var running: bool = false
signal complete


func start():
	await on_start()
	running = true
	
	
func on_start():
	pass
	
	
func stop():
	running = false
	await on_stop()
	complete.emit()
	
	
func on_stop():
	pass
	
	
func should_process() -> bool:
	return running and multiplayer.is_server()


func create_rectangle(length: float, width: float) -> PackedVector2Array:
	var half_length = length / 2.0
	var half_width = width / 2.0
	
	var rectangle_points = PackedVector2Array()
	rectangle_points.append(Vector2(-half_length, -half_width))
	rectangle_points.append(Vector2(half_length, -half_width))
	rectangle_points.append(Vector2(half_length, half_width))
	rectangle_points.append(Vector2(-half_length, half_width))
	
	return rectangle_points
	
	
func create_regular_polygon(points: int, radius: float) -> PackedVector2Array:
	var polygon_points = PackedVector2Array()
	var angle_increment = TAU / points
	
	for i in range(points):
		var angle = i * angle_increment
		var x = radius * cos(angle)
		var y = radius * sin(angle)
		polygon_points.append(Vector2(x, y))
	
	return polygon_points
