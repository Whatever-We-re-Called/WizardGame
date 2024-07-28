# Shard logic modified from https://www.reddit.com/r/godot/comments/nimkqg/how_to_break_a_2d_sprite_in_a_cool_and_easy_way/.
class_name FragileBody2D extends RigidBody2D

@export_category("Shards")
@export_range(0, 200) var number_of_break_points: int = 5
@export var edge_threshold: float = 10.0
@export var length_limit: float = 20

var shard_pieces_parent_node: Node2D
var total_area: float
var minimum_shard_area: float

const MINIMUM_ALLOWED_AREA: float = 400.0
const MINIMUM_ALLOWED_CENTER_DELTA: float = 7.5
const NEARBY_CHECK_RANGE: float = 4.0
const SHARD_PIECE = preload("res://physics/shard_piece.tscn")


func _enter_tree():
	# Scaling and using a parent node to counteract a weird Godot
	# physics bug.
	shard_pieces_parent_node = Node2D.new()
	shard_pieces_parent_node.name = "ShardPieces"
	shard_pieces_parent_node.scale = scale
	add_child(shard_pieces_parent_node)
	
	for child in get_children():
		if child is CollisionPolygon2D:
			total_area = PolygonUtil.get_area_of_polygon(child.polygon)
			break
	minimum_shard_area = total_area / float(number_of_break_points)
	
	freeze = true
	_init_multiplayer_handling()


func _init_multiplayer_handling():
	# TODO MultiplayerSynchronizer
	
	var multiplayer_spawner = MultiplayerSpawner.new()
	add_child(multiplayer_spawner)
	multiplayer_spawner.spawn_path = shard_pieces_parent_node.get_path()
	multiplayer_spawner.add_spawnable_scene(SHARD_PIECE.resource_path)
	
	pass


func break_apart(incoming_collision_polygon: CollisionPolygon2D) -> Array[ShardPiece]:
	var all_created_shards: Array[ShardPiece]
	
	var sprite_polygons_to_break: Array[SpritePolygon2D]
	for child in get_children():
		if child is SpritePolygon2D:
			sprite_polygons_to_break.append(child)
	
	for sprite_polygon in sprite_polygons_to_break:
		var created_shards = _break_apart_sprite(sprite_polygon, incoming_collision_polygon)
		all_created_shards.append_array(created_shards)
	
	return all_created_shards


func _break_apart_sprite(sprite_polygon: SpritePolygon2D, incoming_collision_polygon: CollisionPolygon2D) -> Array[ShardPiece]:
	# Create collision polygon.
	var collision_polygon = sprite_polygon.connected_collision_polygon_2d
	
	# Create overlap polygon.
	var overlap_polygon = _get_overlap_polygon(collision_polygon, incoming_collision_polygon)
	if PolygonUtil.get_area_of_polygon(overlap_polygon) < MINIMUM_ALLOWED_AREA and PolygonUtil.get_area_of_polygon(collision_polygon.polygon) >= MINIMUM_ALLOWED_AREA:
		return []
	elif PolygonUtil.get_smallest_center_delta(overlap_polygon) < MINIMUM_ALLOWED_CENTER_DELTA and PolygonUtil.get_smallest_center_delta(collision_polygon.polygon) >= MINIMUM_ALLOWED_CENTER_DELTA:
		return []
	
	# Create Delaunay.
	var overlap_rect = PolygonUtil.get_rect_from_polygon(overlap_polygon)
	var delaunay = Delaunay.new(overlap_rect)
	delaunay = _get_delaunay_with_placed_points(delaunay, overlap_rect, overlap_polygon)
	
	# Create sites.
	var triangles = delaunay.triangulate()
	var sites = delaunay.make_voronoi(triangles)
	
	# Init shard pieces.
	var shards = _get_shards(sprite_polygon, overlap_polygon, sites)
	
	# Create new sprite polygons.
	var possible_new_shards = _create_new_sprite_polygons(sprite_polygon, collision_polygon, overlap_polygon)
	shards.append_array(possible_new_shards)
	
	queue_redraw()
	return shards


func _get_overlap_polygon(collision_polygon: CollisionPolygon2D, incoming_collision_polygon: CollisionPolygon2D) -> PackedVector2Array:
	var global_collision_polygon = PolygonUtil.get_global_collision_polygon_polygon_from_local(collision_polygon)
	var global_incoming_collision_polygon = PolygonUtil.get_global_collision_polygon_polygon_from_local(incoming_collision_polygon)
	
	var overlap_polygons = Geometry2D.intersect_polygons(global_collision_polygon, global_incoming_collision_polygon)
	var overlap_polygon = overlap_polygons[0] if overlap_polygons.size() > 0 else []
	return PolygonUtil.get_local_polygon_from_global_space(overlap_polygon, self)


func _get_delaunay_with_placed_points(delaunay: Delaunay, overlap_rect: Rect2, overlap_polygon: PackedVector2Array) -> Delaunay:
	for point in overlap_polygon:
		delaunay.add_point(point)
	
	var break_points_chosen = 0
	var attempts = 0
	const MAX_ATTEMPS = 10
	while break_points_chosen < number_of_break_points:
		var possible_point = overlap_rect.position + Vector2(randi_range(0, overlap_rect.size.x), randi_range(0, overlap_rect.size.y))
		
		var ignore_point = false
		for point in delaunay.points:
			if possible_point.distance_to(point) <= length_limit:
				ignore_point = true
		if not ignore_point and not Geometry2D.is_point_in_polygon(possible_point, overlap_polygon):
			ignore_point = true
		
		if not ignore_point:
			delaunay.add_point(possible_point)
			break_points_chosen += 1
		
		attempts += 1
		if attempts >= MAX_ATTEMPS:
			break_points_chosen += 1
			continue
	
	return delaunay


func _get_shards(sprite_polygon: SpritePolygon2D, overlap_polygon: PackedVector2Array, sites: Array) -> Array[ShardPiece]:
	var shards: Array[ShardPiece]
	var texture = sprite_polygon.texture
	
	if PolygonUtil.get_area_of_polygon(overlap_polygon) < minimum_shard_area:
		var shard = _init_shard_piece(overlap_polygon, texture)
		shards.append(shard)
	else:
		for site in sites:
			var center = global_position
			var potential_shard_polygons = Geometry2D.intersect_polygons(overlap_polygon, site.polygon)
			if potential_shard_polygons.size() > 0:
				var shard_polygon = potential_shard_polygons[0]
				var should_disappear = not _is_polygon_a_valid_shard(shard_polygon, false)
				var shard = _init_shard_piece(shard_polygon, texture, should_disappear)
				shards.append(shard)
	
	return shards


func _init_shard_piece(shard_polygon: PackedVector2Array, texture: Texture2D, disappear: bool = false) -> ShardPiece:
	if not multiplayer.is_server(): return null
	
	var shard = SHARD_PIECE.instantiate()
	shard_pieces_parent_node.add_child(shard, true)
	shard.init(shard_polygon, texture, disappear)
	return shard


func _create_new_sprite_polygons(sprite_polygon: SpritePolygon2D, collision_polygon: CollisionPolygon2D, overlap_polygon: PackedVector2Array) -> Array[ShardPiece]:
	var potential_new_shards: Array[ShardPiece]
	
	var potential_non_overlap_polygons = Geometry2D.clip_polygons(collision_polygon.polygon, overlap_polygon)
	for non_overlap_polygon in potential_non_overlap_polygons:
		if _is_polygon_a_valid_shard(non_overlap_polygon):
			non_overlap_polygon = PolygonUtil.remove_far_off_points(non_overlap_polygon)
			
			var new_sprite_polygon = SpritePolygon2D.new()
			new_sprite_polygon.texture = sprite_polygon.texture
			new_sprite_polygon.texture_offset = sprite_polygon.texture_offset
			new_sprite_polygon.polygon = non_overlap_polygon
			add_child(new_sprite_polygon)
			
			var new_collision_polygon = CollisionPolygon2D.new()
			new_collision_polygon.polygon = non_overlap_polygon
			add_child(new_collision_polygon)
			new_sprite_polygon.connected_collision_polygon_2d = new_collision_polygon
		else:
			var new_shard = _init_shard_piece(non_overlap_polygon, sprite_polygon.texture, true)
			potential_new_shards.append(new_shard)
	
	sprite_polygon.kill()
	return potential_new_shards


func _is_polygon_a_valid_shard(polygon: PackedVector2Array, check_nearby_collisions: bool = true) -> bool:
	if PolygonUtil.get_area_of_polygon(polygon) < MINIMUM_ALLOWED_AREA:
		if check_nearby_collisions == true:
			var nearby_collisions = _get_nearby_collisions(NEARBY_CHECK_RANGE, polygon)
			for collision in nearby_collisions:
				if collision.collider is FragileBody2D:
					return true
		return false
	else:
		return true


func _get_nearby_collisions(check_range: float, polygon: PackedVector2Array) -> Array[Dictionary]:
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsShapeQueryParameters2D.new()
	var global_polygon = PolygonUtil.get_global_polygon_from_local_space(polygon, global_position)
	var check_rect = PolygonUtil.get_rect_from_polygon(global_polygon).grow(check_range)
	var check_shape = RectangleShape2D.new()
	check_shape.size = check_rect.size
	query.set_shape(check_shape)
	var check_transform: Transform2D
	check_transform.origin = PolygonUtil.get_center_of_polygon(global_polygon) - (check_rect.size / 2.0)
	query.transform = check_transform
	query.exclude = [self]
	return space_state.intersect_shape(query)
