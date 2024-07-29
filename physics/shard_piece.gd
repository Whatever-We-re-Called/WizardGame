# Shard logic modified from https://www.reddit.com/r/godot/comments/nimkqg/how_to_break_a_2d_sprite_in_a_cool_and_easy_way/.
class_name ShardPiece extends RigidBody2D

var sprite_polygon: SpritePolygon2D
var collision_polygon_2d: CollisionPolygon2D
var disappear: bool
var disappear_timer: Timer

const DISAPPEAR_DELAY = 0.5
const DISAPPEAR_DURATION = 1.0


@rpc("any_peer", "call_local", "reliable")
func init(polygon: PackedVector2Array, texture: Texture2D, texture_offset: Vector2, texture_scale: Vector2, disappear: bool = false):
	self.sprite_polygon = %SpritePolygon2D
	self.collision_polygon_2d = %CollisionPolygon2D
	self.disappear = disappear
	
	# Polygon2D
	sprite_polygon.polygon = polygon
	sprite_polygon.texture = texture
	sprite_polygon.texture_offset = texture_offset
	sprite_polygon.texture_scale = texture_scale
	
	# CollisionPolygon2D
	collision_polygon_2d.polygon = polygon
	
	# RigidBody2D
	center_of_mass_mode = RigidBody2D.CENTER_OF_MASS_MODE_CUSTOM
	center_of_mass = PolygonUtil.get_center_of_polygon(polygon)
	
	contact_monitor = true
	max_contacts_reported = 4
	
	if not multiplayer.is_server():
		freeze_mode = FREEZE_MODE_KINEMATIC
		freeze = true
	
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
		sprite_polygon.self_modulate.a = lerp(0.0, 1.0, disappear_timer.time_left / disappear_timer.wait_time)
