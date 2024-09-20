@tool
class_name SpritePolygon2D extends Polygon2D

@export var generate_polygon_rect: bool:
	set(value):
		if value == true:
			_generate_polygon_rect()

var connected_collision_polygon_2d: CollisionPolygon2D


func _ready() -> void:
	if connected_collision_polygon_2d == null:
		update_collision_polygon()


func update_scaling(new_scale):
	var scaled_polygon = PolygonUtil.get_scaled_polygon(polygon, new_scale)
	
	polygon = scaled_polygon
	texture_scale = Vector2(1.0 / new_scale.x, 1.0 / new_scale.y)
	texture_offset *= new_scale
	
	if connected_collision_polygon_2d != null:
		connected_collision_polygon_2d.polygon = scaled_polygon


func update_collision_polygon() -> void:
	if Engine.is_editor_hint(): return
	
	var new_collision_polygon = PolygonUtil.get_translated_polygon(polygon, offset)
	if connected_collision_polygon_2d == null:
		connected_collision_polygon_2d = CollisionPolygon2D.new()
		connected_collision_polygon_2d.polygon = new_collision_polygon
		get_parent().add_child.call_deferred(connected_collision_polygon_2d)
	else:
		connected_collision_polygon_2d.polygon = new_collision_polygon


func kill():
	queue_free()
	connected_collision_polygon_2d.queue_free()


func _generate_polygon_rect():
	var half_width = texture.get_size().x / 2.0
	var half_height = texture.get_size().y / 2.0
	var polygon_rect: PackedVector2Array
	
	polygon_rect.append(Vector2(-half_width, half_height))
	polygon_rect.append(Vector2(half_width, half_height))
	polygon_rect.append(Vector2(half_width, -half_height))
	polygon_rect.append(Vector2(-half_width, -half_height))
	
	polygon = polygon_rect
	
