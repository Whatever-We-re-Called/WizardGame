# Shard logic modified from https://www.reddit.com/r/godot/comments/nimkqg/how_to_break_a_2d_sprite_in_a_cool_and_easy_way/.
class_name ShardPiece extends RigidBody2D

var sprite_polygon: SpritePolygon2D
var disappear: bool
var disappear_timer: Timer

const DISAPPEAR_DELAY = 0.5
const DISAPPEAR_DURATION = 1.0


@rpc("any_peer", "call_local", "reliable")
func init(polygon: PackedVector2Array, texture: Texture2D, texture_offset: Vector2, texture_scale: Vector2, disappear: bool = false):
	self.sprite_polygon = %SpritePolygon2D
	self.disappear = disappear
	
	var polygon_global = PolygonUtil.get_global_polygon_from_local_space(polygon, global_position)
	var position_delta = PolygonUtil.get_center_of_polygon(polygon_global) - global_position
	global_position += position_delta
	var corrected_polygon = PolygonUtil.get_translated_polygon(polygon, -position_delta)
	
	# SpritePolygon2D
	sprite_polygon.polygon = corrected_polygon
	sprite_polygon.texture = texture
	sprite_polygon.texture_offset = texture_offset + position_delta
	sprite_polygon.texture_scale = texture_scale
	sprite_polygon.update_collision_polygon()
	
	# RigidBody2D
	center_of_mass_mode = RigidBody2D.CENTER_OF_MASS_MODE_CUSTOM
	center_of_mass = PolygonUtil.get_center_of_polygon(corrected_polygon)
	
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
