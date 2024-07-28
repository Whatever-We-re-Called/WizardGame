class_name SpritePolygon2D extends Polygon2D

@export var connected_collision_polygon_2d: CollisionPolygon2D


func update_scaling(new_scale):
	var scaled_polygon = PolygonUtil.get_scaled_polygon(polygon, new_scale)
	
	polygon = scaled_polygon
	texture_scale = Vector2(1.0 / new_scale.x, 1.0 / new_scale.y)
	texture_offset *= new_scale
	
	connected_collision_polygon_2d.polygon = scaled_polygon


func kill():
	queue_free()
	connected_collision_polygon_2d.queue_free()
