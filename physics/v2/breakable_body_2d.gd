class_name BreakableBody2D extends CharacterBody2D

@export var data: BreakableData

var shard_polygons: Array[PackedVector2Array]

const DISPLAY_VORONOI_DEBUG: bool = true
const EDGE_THRESHOLD: float = 10.0
const BREAK_POINT_DISTANCE_MINIMUM: float = 20.0
const MAX_FAILED_BREAK_POINT_ATTEMPTS: int = 100


func update_physics_layer():
	PhysicsUtil.place_onto_environment_layer(self, data.layer, true)


func create_shard_polygons():
	var primary_polygon = _get_primary_polygon()
	if primary_polygon.size() == 0:
		push_error("Could not create a valid primary polygon for BreakableBody2D.")
		return
	
	var sites = _get_voronoi_sites(primary_polygon)
	for site in sites:
		var potential_shard_polygons = Geometry2D.intersect_polygons(primary_polygon, site.polygon)
		if potential_shard_polygons.size() > 0:
			var shard_polygon = potential_shard_polygons[0]
			shard_polygons.append(shard_polygon)
	
	if DISPLAY_VORONOI_DEBUG == true:
		for shard_polygon in shard_polygons:
			PolygonUtil.create_debug_collision_polygon(shard_polygon, self, Color.WHITE)


#region create_shard_polygons Helper Methods
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
