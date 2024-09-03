class_name BreakableBody2D extends RigidBody2D

@export var data: BreakableData

var fragment_polygons: Array[PackedVector2Array]
var id: int
var texture: Texture2D
var texture_offset: Vector2
var texture_scale: Vector2

const DISPLAY_VORONOI_DEBUG: bool = true
const EDGE_THRESHOLD: float = 10.0
const BREAK_POINT_DISTANCE_MINIMUM: float = 20.0
const MAX_FAILED_BREAK_POINT_ATTEMPTS: int = 100

# Note about frequent use of preload(). 
# If done as a constant, "circular dependency" occurs, which results in class
# definitions entering the tree without proper references hooked up.
# https://en.wikipedia.org/wiki/Circular_dependency
# https://www.reddit.com/r/godot/comments/1643fgi/circular_dependency_issues/


func _enter_tree() -> void:
	_init_multiplayer_handling()
	#_update_physics_layer()


func _init_multiplayer_handling():
	set_multiplayer_authority(1)
	
	if is_multiplayer_authority():
		var new_id = PhysicsManager.get_new_shard_id()
		_apply_new_id.rpc(new_id)
		PhysicsManager.append_active_shard(self)
	
	var multiplayer_spawner = MultiplayerSpawner.new()
	add_child(multiplayer_spawner, true)
	multiplayer_spawner.spawn_path = get_path()
	multiplayer_spawner.add_spawnable_scene("res://physics/v2/spawnable_scenes/shard_body_scene.tscn")
	multiplayer_spawner.add_spawnable_scene("res://physics/v2/spawnable_scenes/shard_chunk_scene.tscn")
	multiplayer_spawner.add_spawnable_scene("res://physics/v2/spawnable_scenes/shard_piece_scene.tscn")


@rpc("authority", "call_local", "reliable")
func _apply_new_id(new_id: int):
	self.id = new_id


func _update_physics_layer():
	PhysicsUtil.place_onto_environment_layer(self, data.layer, true)


#region Create fragment polygons.
func create_fragment_polygons():
	var primary_shard_polygon = _get_primary_shard_polygon()
	if primary_shard_polygon == null:
		return
	
	texture = primary_shard_polygon.texture
	print(texture)
	texture_offset = primary_shard_polygon.texture_offset
	texture_scale = primary_shard_polygon.texture_scale
	
	if multiplayer.is_server():
		var sites = _get_voronoi_sites(primary_shard_polygon.polygon)
		for site in sites:
			var potential_fragment_polygons = Geometry2D.intersect_polygons(primary_shard_polygon.polygon, site.polygon)
			if potential_fragment_polygons.size() > 0:
				var fragment_polygon = potential_fragment_polygons[0]
				fragment_polygons.append(fragment_polygon)
		
		if DISPLAY_VORONOI_DEBUG == true and get_tree().debug_collisions_hint == true:
			for fragment_polygon in fragment_polygons:
				PolygonUtil.create_debug_collision_polygon(fragment_polygon, self, Color.WHITE)


func _get_primary_shard_polygon() -> ShardPolygon:
	for child in get_children():
		if child is ShardPolygon:
			return child
	
	push_error("Could not create a valid primary polygon for BreakableBody2D.")
	return null


func _get_voronoi_sites(primary_polygon: PackedVector2Array) -> Array:
	var rect = PolygonUtil.get_rect_from_polygon(primary_polygon)
	var delaunay = Delaunay.new(rect)
	delaunay = _get_delaunay_with_placed_points(delaunay, primary_polygon, rect)
	
	var triangles = delaunay.triangulate()
	return delaunay.make_voronoi(triangles)


func _get_delaunay_with_placed_points(delaunay: Delaunay, primary_polygon: PackedVector2Array, rect: Rect2) -> Delaunay:
	for point in primary_polygon:
		delaunay.add_point(point)
	
	var break_points_placed = 0
	var failed_attempts = 0
	while break_points_placed < data.number_of_break_points:
		var possible_point = rect.position + Vector2(randi_range(0, rect.size.x), randi_range(0, rect.size.y))
		
		if _is_valid_break_point(possible_point, delaunay, primary_polygon):
			delaunay.add_point(possible_point)
			break_points_placed += 1
		else:
			failed_attempts += 1
			if failed_attempts > MAX_FAILED_BREAK_POINT_ATTEMPTS:
				break
	
	return delaunay


func _is_valid_break_point(possible_point: Vector2, delaunay: Delaunay, primary_polygon: PackedVector2Array) -> bool:
	for point in delaunay.points:
		if possible_point.distance_to(point) < BREAK_POINT_DISTANCE_MINIMUM:
			return false
	
	if not Geometry2D.is_point_in_polygon(possible_point, primary_polygon):
		return false
	
	return true
#endregion


#region Break apart bodies and chunks.
func break_apart_from_collision(incoming_collision_polygon: CollisionPolygon2D, applied_impulse: Vector2):
	var shard_polygons_to_break: Array[ShardPolygon]
	for child in get_children():
		if child is ShardPolygon:
			shard_polygons_to_break.append(child)
	
	for shard_polygon in shard_polygons_to_break:
		if incoming_collision_polygon == null:
			_break_apart_polygon(shard_polygon, shard_polygon.collision_polygon, applied_impulse)
		else:
			_break_apart_polygon(shard_polygon, incoming_collision_polygon, applied_impulse)


func _break_apart_polygon(shard_polygon: ShardPolygon, incoming_collision_polygon: CollisionPolygon2D, impulse: Vector2):
	var overlap_polygon = _get_overlap_polygon(shard_polygon.collision_polygon, incoming_collision_polygon)
	
	_create_new_shards(shard_polygon, overlap_polygon)
	_create_non_overlap_shard_polygons(shard_polygon, shard_polygon.collision_polygon, overlap_polygon)
	
	queue_redraw()


func _get_overlap_polygon(collision_polygon: CollisionPolygon2D, incoming_collision_polygon: CollisionPolygon2D) -> PackedVector2Array:
	var global_collision_polygon = PolygonUtil.get_global_collision_polygon_polygon_from_local(collision_polygon)
	var global_incoming_collision_polygon = PolygonUtil.get_global_collision_polygon_polygon_from_local(incoming_collision_polygon)
	
	var overlap_polygons = Geometry2D.intersect_polygons(global_collision_polygon, global_incoming_collision_polygon)
	var overlap_polygon = overlap_polygons[0] if overlap_polygons.size() > 0 else []
	return PolygonUtil.get_local_polygon_from_global_space(overlap_polygon, self)


func _create_new_shards(shard_polygon: ShardPolygon, overlap_polygon: PackedVector2Array):
	if not multiplayer.is_server(): return
	
	if self is ShardBody:
		print("Shard body!")
		for fragment_polygon in fragment_polygons:
			var potential_fragment_polygons = Geometry2D.intersect_polygons(overlap_polygon, fragment_polygon)
			if potential_fragment_polygons.size() > 0:
				var intersect_polygon = potential_fragment_polygons[0]
				_init_shard_chunk(intersect_polygon, shard_polygon)


func _create_non_overlap_shard_polygons(shard_polygon: ShardPolygon, collision_polygon: CollisionPolygon2D, overlap_polygon: PackedVector2Array):
	var potential_non_overlap_polygons = Geometry2D.clip_polygons(collision_polygon.polygon, overlap_polygon)
	for non_overlap_polygon in potential_non_overlap_polygons:
		non_overlap_polygon = PolygonUtil.remove_far_off_points(non_overlap_polygon)
		
		var new_shard_polygon = ShardPolygon.new()
		new_shard_polygon.polygon = non_overlap_polygon
		new_shard_polygon.texture = shard_polygon.texture
		new_shard_polygon.texture_offset = shard_polygon.texture_offset
		new_shard_polygon.texture_scale = shard_polygon.texture_scale
		add_child(new_shard_polygon, true)
	
	scale = Vector2.ONE
	shard_polygon.destroy()
#endregion


#region Initialize bodies, chunks, and pieces.
func _init_shard_chunk(intersect_polygon: PackedVector2Array, shard_polygon: ShardPolygon):
	var shard_chunk = preload("res://physics/v2/spawnable_scenes/shard_chunk_scene.tscn").instantiate()
	shard_chunk.data = data.duplicate()
	add_child(shard_chunk, true)
	
	shard_chunk._init_self_shard_polygon_rpc.rpc(intersect_polygon)
	
	shard_chunk._on_creation()


@rpc("authority", "call_local", "reliable")
func _init_self_shard_polygon_rpc(polygon: PackedVector2Array):
	var polygon_global = PolygonUtil.get_global_polygon_from_local_space(polygon, global_position)
	var position_delta = PolygonUtil.get_center_of_polygon(polygon_global) - global_position
	global_position += position_delta
	var corrected_polygon = PolygonUtil.get_translated_polygon(polygon, -position_delta)
	
	var parent_shard_polygon = get_parent()._get_primary_shard_polygon()
	var shard_polygon = %ShardPolygon
	print(shard_polygon)
	shard_polygon.polygon = corrected_polygon
	shard_polygon.texture = get_parent().texture
	shard_polygon.texture_offset = get_parent().texture_offset + position_delta
	shard_polygon.texture_scale = get_parent().texture_scale
	shard_polygon.update_collision_polygon()
	
	center_of_mass_mode = RigidBody2D.CENTER_OF_MASS_MODE_CUSTOM
	center_of_mass = PolygonUtil.get_center_of_polygon(corrected_polygon)
#endregion


func _on_creation() -> void:
	# Intended to be overridden in shard scripts.
	pass


@export var replicated_position: Vector2
@export var replicated_rotation: float
@export var replicated_linear_velocity: Vector2
@export var replicated_angular_velocity: float
func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if is_multiplayer_authority():
		replicated_position = position
		replicated_rotation = rotation
		replicated_linear_velocity = linear_velocity
		replicated_angular_velocity = angular_velocity
	else:
		freeze_mode = FREEZE_MODE_KINEMATIC
		freeze = true
		position = replicated_position
		rotation = replicated_rotation
		linear_velocity = replicated_linear_velocity
		angular_velocity = replicated_angular_velocity
