class_name BreakableBody2D extends RigidBody2D

enum EnvironmentLayer { FRONT, BASE, BACK, ALL }

@export var data: BreakableData

var health: float
var fragment_polygons: Array[PackedVector2Array]
var id: int
var texture: Texture2D
var texture_offset: Vector2
var texture_scale: Vector2
var total_area: float

const DISPLAY_VORONOI_DEBUG: bool = true
const EDGE_THRESHOLD: float = 10.0
const BREAK_POINT_DISTANCE_MINIMUM: float = 20.0
const MAX_FAILED_BREAK_POINT_ATTEMPTS: int = 100
const MINIMUM_CHUNK_AREA = 2000
const MINIMUM_NON_OVERLAP_AREA = 200

# Note about frequent use of preload(). 
# If done as a constant, "circular dependency" occurs, which results in class
# definitions entering the tree without proper references hooked up.
# https://en.wikipedia.org/wiki/Circular_dependency
# https://www.reddit.com/r/godot/comments/1643fgi/circular_dependency_issues/


func _enter_tree() -> void:
	_init_health()
	_init_multiplayer_handling()
	_init_scaling()
	_update_physics_layer()
	_init_area_handling()



func _init_health():
	if data == null: return
	
	health = data.max_health


func _init_multiplayer_handling():
	set_multiplayer_authority(1)
	
	var multiplayer_spawner = MultiplayerSpawner.new()
	add_child(multiplayer_spawner, true)
	multiplayer_spawner.spawn_path = get_path()
	multiplayer_spawner.add_spawnable_scene("res://physics/v2/spawnable_scenes/shard_body_scene.tscn")
	multiplayer_spawner.add_spawnable_scene("res://physics/v2/spawnable_scenes/shard_chunk_scene.tscn")
	multiplayer_spawner.add_spawnable_scene("res://physics/v2/spawnable_scenes/shard_piece_scene.tscn")
	multiplayer_spawner.add_spawnable_scene("res://physics/v2/spawnable_scenes/shard_polygon_scene.tscn")


func _init_scaling():
	for child in get_children():
		if child is ShardPolygon:
			child.update_scaling(scale)
	
	scale = Vector2.ONE


func _update_physics_layer():
	if data == null: return
	
	BreakablePhysicsUtil.place_onto_environment_layer(self, data.layer, true)


func _init_area_handling():
	total_area = PolygonUtil.get_area_of_polygon(_get_primary_shard_polygon().polygon)

 
func _handle_data_update():
	_init_health()
	_update_physics_layer()
	_init_area_handling()


#region Create fragment polygons.
func create_fragment_polygons():
	var primary_shard_polygon = _get_primary_shard_polygon()
	if primary_shard_polygon == null:
		return
	
	texture = primary_shard_polygon.texture
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
func break_apart_from_collision(incoming_collision_polygon: CollisionPolygon2D, impulse_callable: Callable):
	var shard_polygons_to_break: Array[ShardPolygon]
	for child in get_children():
		if child is ShardPolygon:
			shard_polygons_to_break.append(child)
	
	for shard_polygon in shard_polygons_to_break:
		if incoming_collision_polygon == null:
			_break_apart_polygon(shard_polygon, shard_polygon.collision_polygon, impulse_callable)
		else:
			_break_apart_polygon(shard_polygon, incoming_collision_polygon, impulse_callable)


func _break_apart_polygon(shard_polygon: ShardPolygon, incoming_collision_polygon: CollisionPolygon2D, impulse_callable: Callable):
	var overlap_polygons = _get_overlap_polygon(shard_polygon.collision_polygon, incoming_collision_polygon)
	for overlap_polygon in overlap_polygons:
		_create_new_shards(overlap_polygon, impulse_callable)
	
	_create_non_overlap_shard_polygons(shard_polygon.collision_polygon, incoming_collision_polygon)
	
	scale = Vector2.ONE
	shard_polygon.destroy()
	
	queue_redraw()


func _get_overlap_polygon(collision_polygon: CollisionPolygon2D, incoming_collision_polygon: CollisionPolygon2D) -> Array[PackedVector2Array]:
	var global_collision_polygon = PolygonUtil.get_global_collision_polygon_polygon_from_local(collision_polygon)
	var global_incoming_collision_polygon = PolygonUtil.get_global_collision_polygon_polygon_from_local(incoming_collision_polygon)
	
	var overlap_polygons = Geometry2D.intersect_polygons(global_collision_polygon, global_incoming_collision_polygon)
	
	var result: Array[PackedVector2Array]
	for overlap_polygon in overlap_polygons:
		result.append(PolygonUtil.get_local_polygon_from_global_space(overlap_polygon, self))
	return result


func _create_new_shards(overlap_polygon: PackedVector2Array, impulse_callable: Callable):
	if not multiplayer.is_server(): return
	
	var is_creating_pieces = PolygonUtil.get_area_of_polygon(overlap_polygon) < MINIMUM_CHUNK_AREA
	
	for fragment_polygon in fragment_polygons:
		var potential_fragment_polygons = Geometry2D.intersect_polygons(overlap_polygon, fragment_polygon)
		if potential_fragment_polygons.size() > 0:
			var intersect_polygon = potential_fragment_polygons[0]
			
			if is_creating_pieces:
				_init_shard_piece(intersect_polygon, impulse_callable)
			else:
				_init_shard_chunk(intersect_polygon, impulse_callable)


func _create_non_overlap_shard_polygons(collision_polygon: CollisionPolygon2D, incoming_collision_polygon: CollisionPolygon2D):
	var global_collision_polygon = PolygonUtil.get_global_collision_polygon_polygon_from_local(collision_polygon)
	var global_incoming_collision_polygon = PolygonUtil.get_global_collision_polygon_polygon_from_local(incoming_collision_polygon)
	var potential_non_overlap_polygons = Geometry2D.clip_polygons(global_collision_polygon, global_incoming_collision_polygon)
	
	var non_overlap_polygons: Array[PackedVector2Array]
	for potential_non_overlap_polygon in potential_non_overlap_polygons:
		non_overlap_polygons.append(PolygonUtil.get_local_polygon_from_global_space(potential_non_overlap_polygon, self))
	
	for non_overlap_polygon in non_overlap_polygons:
		non_overlap_polygon = PolygonUtil.remove_far_off_points(non_overlap_polygon)
		
		if PolygonUtil.get_area_of_polygon(non_overlap_polygon) > MINIMUM_NON_OVERLAP_AREA:
			var new_shard_polygon = preload("res://physics/spawnable_scenes/shard_polygon_scene.tscn").instantiate()
			add_child(new_shard_polygon, true)
			new_shard_polygon.init_non_overlap_shard_polygon_rpc.rpc(non_overlap_polygon)
#endregion


#region Initialize bodies, chunks, and pieces.
func _init_shard_chunk(intersect_polygon: PackedVector2Array, impulse_callable: Callable):
	var shard_chunk = preload("res://physics/spawnable_scenes/shard_chunk_scene.tscn").instantiate()
	_init_shard(shard_chunk, intersect_polygon, impulse_callable)


func _init_shard_piece(intersect_polygon: PackedVector2Array, impulse_callable: Callable):
	var shard_piece = preload("res://physics/spawnable_scenes/shard_piece_scene.tscn").instantiate()
	_init_shard(shard_piece, intersect_polygon, impulse_callable)


func _init_shard(new_shard: BreakableBody2D, intersect_polygon: PackedVector2Array, impulse_callable: Callable):
	add_child(new_shard, true)
	
	var area_ratio = PolygonUtil.get_area_of_polygon(intersect_polygon) / total_area
	new_shard._init_self_shard_polygon_rpc.rpc(intersect_polygon, data.get_as_dictionary(), area_ratio)
	new_shard._on_creation()
	
	var applied_impulse = impulse_callable.call(new_shard)
	new_shard.apply_central_impulse(applied_impulse)


@rpc("authority", "call_local", "reliable")
func _init_self_shard_polygon_rpc(polygon: PackedVector2Array, data_dictionary: Dictionary, area_ratio: float):
	var polygon_global = PolygonUtil.get_global_polygon_from_local_space(polygon, global_position)
	var position_delta = PolygonUtil.get_center_of_polygon(polygon_global) - global_position
	global_position += position_delta
	var corrected_polygon = PolygonUtil.get_translated_polygon(polygon, -position_delta)
	
	var shard_polygon = %ShardPolygon
	shard_polygon.polygon = corrected_polygon
	shard_polygon.texture = get_parent().texture
	shard_polygon.texture_offset = get_parent().texture_offset + position_delta
	shard_polygon.texture_scale = get_parent().texture_scale
	shard_polygon.update_collision_polygon()
	
	data = BreakableData.get_from_dictionary(data_dictionary)
	data.number_of_break_points = int(data.number_of_break_points * area_ratio)
	_handle_data_update()
	
	center_of_mass_mode = RigidBody2D.CENTER_OF_MASS_MODE_CUSTOM
	center_of_mass = PolygonUtil.get_center_of_polygon(corrected_polygon)
#endregion


#region Damage handling
func damage(damage_dealt: float, impulse_callable: Callable) -> Array[PhysicsBody2D]:
	return damage_with_collision(damage_dealt, impulse_callable)


# TODO Re-approach how this is handled. I don't think this has good game feel.
func damage_with_collision(damage_dealt: float, impulse_callable: Callable, collision_polygon: CollisionPolygon2D = null):
	if health <= 0:
		break_apart_from_collision(
			_get_incoming_collision_polygon_for_damage(collision_polygon),
			impulse_callable
		)
	else:
		health -= damage_dealt
		
		if health <= 0:
			break_apart_from_collision(
				_get_incoming_collision_polygon_for_damage(collision_polygon),
				impulse_callable
			)


func _get_incoming_collision_polygon_for_damage(collision_polygon: CollisionPolygon2D = null) -> CollisionPolygon2D:
	var incoming_collision_polygon: CollisionPolygon2D
	if collision_polygon == null:
		incoming_collision_polygon = CollisionPolygon2D.new()
		incoming_collision_polygon.polygon = _get_primary_shard_polygon().polygon
	else:
		incoming_collision_polygon = collision_polygon
	
	return incoming_collision_polygon
#endregion


func _on_creation() -> void:
	# Intended to be overridden in shard scripts.
	pass
