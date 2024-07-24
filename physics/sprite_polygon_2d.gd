class_name SpritePolygon2D extends Polygon2D

@export var connected_collision_polygon_2d: CollisionPolygon2D


func kill():
	queue_free()
	connected_collision_polygon_2d.queue_free()
