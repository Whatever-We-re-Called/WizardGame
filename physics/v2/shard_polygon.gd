@tool
class_name ShardPolygon extends Polygon2D

@export var generate_first_pass_polygon: bool:
	set(value):
		_generate_first_pass_polygon()

var collision_polygon: CollisionPolygon2D


func _ready() -> void:
	item_rect_changed.connect(_on_item_rect_changed)
	
	if not Engine.is_editor_hint():
		update_collision_polygon()


func _on_item_rect_changed():
	if Engine.is_editor_hint():
		texture_offset = texture.get_size() / 2.0


func update_collision_polygon():
	if collision_polygon == null:
		_create_collision_polygon()
	
	collision_polygon.polygon = polygon


func _create_collision_polygon():
	collision_polygon = CollisionPolygon2D.new()
	collision_polygon.set_name("CollisionPolygon2D")
	# Needs to be deferred to allow proper time for parent initilization.
	get_parent().call_deferred("add_child", collision_polygon)


func _generate_first_pass_polygon():
	var image = texture.get_image()
	var bitmap = BitMap.new()
	bitmap.create_from_image_alpha(image)
	
	var polygons = bitmap.opaque_to_polygons(Rect2(Vector2(0, 0), bitmap.get_size()), 10.0)
	if polygons.size() > 0:
		polygon = PolygonUtil.get_translated_polygon(polygons[0], -texture.get_size() / 2.0)


@rpc("any_peer", "call_local", "reliable")
func init_non_overlap_shard_polygon_rpc(non_overlap_polygon: PackedVector2Array):
	var body = get_parent()
	if not body is RigidBody2D: return
	
	polygon = non_overlap_polygon
	texture = body.texture
	texture_offset = body.texture_offset
	texture_scale = body.texture_scale
	update_collision_polygon()


func destroy():
	destroy_rpc.rpc()


@rpc("any_peer", "call_local", "reliable")
func destroy_rpc():
	call_deferred("queue_free")
	collision_polygon.call_deferred("queue_free")
