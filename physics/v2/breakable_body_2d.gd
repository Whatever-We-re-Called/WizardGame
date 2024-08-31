class_name BreakableBody2D extends CharacterBody2D

@export var data: BreakableData

var fragment_polygons: Array[PackedVector2Array]

const DISPLAY_VORONOI_DEBUG: bool = true
const EDGE_THRESHOLD: float = 10.0
const BREAK_POINT_DISTANCE_MINIMUM: float = 20.0
const MAX_FAILED_BREAK_POINT_ATTEMPTS: int = 100


func update_physics_layer():
	PhysicsUtil.place_onto_environment_layer(self, data.layer, true)


#region Create fragment polygons.
func create_shard_polygons():
	var primary_polygon = _get_primary_polygon()
	if primary_polygon.size() == 0:
		push_error("Could not create a valid primary polygon for BreakableBody2D.")
		return
	
	var sites = _get_voronoi_sites(primary_polygon)
	for site in sites:
		var potential_fragment_polygons = Geometry2D.intersect_polygons(primary_polygon, site.polygon)
		if potential_fragment_polygons.size() > 0:
			var fragment_polygon = potential_fragment_polygons[0]
			fragment_polygons.append(fragment_polygon)
	
	if DISPLAY_VORONOI_DEBUG == true:
		for fragment_polygon in fragment_polygons:
			PolygonUtil.create_debug_collision_polygon(fragment_polygon, self, Color.WHITE)


func _get_primary_polygon() -> PackedVector2Array:
	for child in get_children():
		if child is ShardPolygon:
			return child.polygon
	return []


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
				continue
	
	return delaunay


func _is_valid_break_point(possible_point: Vector2, delaunay: Delaunay, primary_polygon: PackedVector2Array) -> bool:
	for point in delaunay.points:
		if possible_point.distance_to(point) < BREAK_POINT_DISTANCE_MINIMUM:
			return false
	
	if not Geometry2D.is_point_in_polygon(possible_point, primary_polygon):
		return false
	
	return true
#endregion


#region Breake apart bodies and chunks.
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
	
	## Create new sprite polygons.
	#var possible_new_shards = _create_new_sprite_polygons(sprite_polygon, collision_polygon, overlap_polygon)
	#shards.append_array(possible_new_shards)
	#
	#queue_redraw()
	#return shards


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
#endregion


#region Initialize bodies, chunks, and pieces.
func _init_shard_chunk(intersect_polygon: PackedVector2Array, shard_polygon: ShardPolygon):
	var shard_chunk = ShardChunk.new()
	add_child(shard_chunk, true)
	shard_chunk._init_self_rpc.rpc(intersect_polygon, shard_polygon.texture, shard_polygon.texture_offset, shard_polygon.texture_scale)


@rpc("any_peer", "call_local", "reliable")
func _init_self_rpc(polygon: PackedVector2Array, texture: Texture2D, texture_offset: Vector2, texture_scale: Vector2):
	var polygon_global = PolygonUtil.get_global_polygon_from_local_space(polygon, global_position)
	var position_delta = PolygonUtil.get_center_of_polygon(polygon_global) - global_position
	global_position += position_delta
	var corrected_polygon = PolygonUtil.get_translated_polygon(polygon, -position_delta)
	
	var shard_polygon = ShardPolygon.new()
	shard_polygon.polygon = corrected_polygon
	shard_polygon.texture = texture
	shard_polygon.texture_offset = texture_offset + position_delta
	shard_polygon.texture_scale = texture_scale
	add_child(shard_polygon)
#endregion
