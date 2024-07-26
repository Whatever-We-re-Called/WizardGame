# Shard logic modified from https://www.reddit.com/r/godot/comments/nimkqg/how_to_break_a_2d_sprite_in_a_cool_and_easy_way/.
class_name ShardPiece extends RigidBody2D

var polygon_2d: Polygon2D
var collision_polygon_2d: CollisionPolygon2D
var disappear_timer: Timer

const DISAPPEAR_DELAY = 0.5
const DISAPPEAR_DURATION = 1.0


func init(polygon: PackedVector2Array, texture: Texture2D, disappear: bool = false):
	self.polygon_2d = %Polygon2D
	self.collision_polygon_2d = %CollisionPolygon2D
	
	# Polygon2D
	polygon_2d.polygon = polygon
	polygon_2d.texture = texture
	if texture is CompressedTexture2D:
		polygon_2d.texture_offset = texture.get_size() / 2.0
	
	# CollisionPolygon2D
	collision_polygon_2d.polygon = polygon
	
	# RigidBody2D
	center_of_mass_mode = RigidBody2D.CENTER_OF_MASS_MODE_CUSTOM
	center_of_mass = PolygonUtil.get_center_of_polygon(polygon)
	
	contact_monitor = true
	max_contacts_reported = 4
	
	if disappear == true:
		_disappear()


func _disappear():
	await get_tree().create_timer(DISAPPEAR_DELAY).timeout
	await body_entered
	
	disappear_timer = Timer.new()
	disappear_timer.one_shot = true
	disappear_timer.wait_time = DISAPPEAR_DURATION
	disappear_timer.timeout.connect(queue_free)
	add_child(disappear_timer)
	disappear_timer.start()


func _process(delta):
	if disappear_timer != null:
		polygon_2d.self_modulate.a = lerp(0.0, 1.0, disappear_timer.time_left / disappear_timer.wait_time)
