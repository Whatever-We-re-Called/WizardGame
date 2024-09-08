class_name CollisionChannel extends Area2D

var collision_polygon

const PHYSICS_FRAMES_UNTIL_CREATION: int = 2
const PHYSICS_FRAMES_UNTIL_POLYGON_UPDATE: int = 1


func _init() -> void:
	collision_polygon = CollisionPolygon2D.new()
	add_child(collision_polygon)
	
	for i in range(PHYSICS_FRAMES_UNTIL_CREATION):
		await Engine.get_main_loop().physics_frame


func update_polygon(polygon: PackedVector2Array):
	collision_polygon.polygon = polygon
	
	for i in range(PHYSICS_FRAMES_UNTIL_POLYGON_UPDATE):
		await Engine.get_main_loop().physics_frame


func reset_polygon():
	collision_polygon.polygon = []
