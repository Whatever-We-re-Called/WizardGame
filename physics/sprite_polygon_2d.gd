class_name SpritePolygon2D extends Polygon2D

var connected_collision_polygon_2d: CollisionPolygon2D


func _ready() -> void:
	create_connected_polygon()


func update_scaling(new_scale):
	var scaled_polygon = PolygonUtil.get_scaled_polygon(polygon, new_scale)
	
	polygon = scaled_polygon
	texture_scale = Vector2(1.0 / new_scale.x, 1.0 / new_scale.y)
	texture_offset *= new_scale
	
	if connected_collision_polygon_2d == null:
		create_connected_polygon(scaled_polygon)
	else:
		connected_collision_polygon_2d.polygon = scaled_polygon


func create_connected_polygon(polygon_override: PackedVector2Array = []) -> void:
	if connected_collision_polygon_2d != null: return
	
	connected_collision_polygon_2d = CollisionPolygon2D.new()
	if polygon_override.is_empty():
		connected_collision_polygon_2d.polygon = polygon
	else:
		connected_collision_polygon_2d.polygon = polygon_override
	
	get_parent().add_child.call_deferred(connected_collision_polygon_2d)


func kill():
	queue_free()
	connected_collision_polygon_2d.queue_free()
