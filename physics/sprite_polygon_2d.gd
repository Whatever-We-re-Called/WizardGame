class_name SpritePolygon2D extends Polygon2D

var connected_collision_polygon_2d: CollisionPolygon2D


func _ready() -> void:
	if connected_collision_polygon_2d == null:
		update_collision_polygon()


func update_scaling(new_scale):
	var scaled_polygon = PolygonUtil.get_scaled_polygon(polygon, new_scale)
	
	polygon = scaled_polygon
	texture_scale = Vector2(1.0 / new_scale.x, 1.0 / new_scale.y)
	texture_offset *= new_scale
	
	if connected_collision_polygon_2d == null:
		update_collision_polygon()
	else:
		connected_collision_polygon_2d.polygon = scaled_polygon


func update_collision_polygon() -> void:
	if connected_collision_polygon_2d == null:
		connected_collision_polygon_2d = CollisionPolygon2D.new()
		connected_collision_polygon_2d.polygon = polygon
		get_parent().add_child.call_deferred(connected_collision_polygon_2d)
	else:
		connected_collision_polygon_2d.polygon = polygon


func kill():
	queue_free()
	connected_collision_polygon_2d.queue_free()
