class_name PolygonUtil


static func get_center_of_polygon(polygon: PackedVector2Array) -> Vector2:
	var number_of_vertices = polygon.size()
	var vertices_x_sum: float
	var vertices_y_sum: float
	for poly in polygon:
		vertices_x_sum += poly.x
		vertices_y_sum += poly.y
	var center_of_mass_x = float(vertices_x_sum) / float(number_of_vertices)
	var center_of_mass_y = float(vertices_y_sum) / float(number_of_vertices)
	return Vector2(center_of_mass_x, center_of_mass_y)


static func get_global_collision_polygon_polygon_from_local(collision_polygon: CollisionPolygon2D) -> PackedVector2Array:
	var result: PackedVector2Array
	for point in collision_polygon.polygon:
		var position = Vector2(point.x + collision_polygon.global_position.x, point.y + collision_polygon.global_position.y)
		result.append(position)
	
	return result


static func get_global_polygon_from_local_space(polygon: PackedVector2Array, global_position: Vector2) -> PackedVector2Array:
	var result: PackedVector2Array
	
	for point in polygon:
		var new_x = point.x + global_position.x
		var new_y = point.y + global_position.y
		result.append(Vector2(new_x, new_y))
	
	return result


static func get_local_polygon_from_global_space(polygon: PackedVector2Array, parent_node: Node2D) -> PackedVector2Array:
	var offset = get_center_of_polygon(polygon)
	var result: PackedVector2Array
	
	for point in polygon:
		var new_x = point.x - parent_node.position.x
		var new_y = point.y - parent_node.position.y
		result.append(Vector2(new_x, new_y))
	
	return result


static func create_debug_collision_polygon(polygon: PackedVector2Array, parent: Node2D, modulate_color: Color = Color.WHITE, duration: float = 1.0):
	var debug_polygon = CollisionPolygon2D.new()
	debug_polygon.polygon = polygon
	debug_polygon.self_modulate = modulate_color
	parent.add_child(debug_polygon)
	await parent.get_tree().create_timer(duration).timeout
	
	if debug_polygon != null:
		debug_polygon.queue_free()


static func get_area_of_polygon(polygon: PackedVector2Array) -> float:
	var result_a: float
	var result_b: float
	for i in range(polygon.size()):
		result_a += polygon[i].x * polygon[(i + 1) % polygon.size()].y
		result_b += polygon[(i + 1) % polygon.size()].x * polygon[i].y
	
	return (result_a - result_b) / 2.0


static func get_rect_from_polygon(polygon: PackedVector2Array) -> Rect2:
	const MAX_COORD = pow(2, 31) - 1
	var min_point = Vector2(MAX_COORD, MAX_COORD)
	var max_point = Vector2(-MAX_COORD, -MAX_COORD)
	for point in polygon:
		min_point = Vector2(min(min_point.x, point.x), min(min_point.y, point.y))
		max_point = Vector2(max(max_point.x, point.x), max(max_point.y, point.y))
	
	return Rect2(min_point, max_point - min_point)


static func does_polygon_have_repeated_point(polygon: PackedVector2Array) -> bool:
	var checked_points: Array[Vector2]
	for point in polygon:
		if checked_points.has(point):
			return true
		checked_points.append(point)
	
	return false


static func does_polygon_contain_a_line(polygon: PackedVector2Array, max_threshold: float) -> bool:
	for i in range(polygon.size()):
		var slope_a = (polygon[(i + 1) % polygon.size()].y - polygon[i].y) - (polygon[(i + 1) % polygon.size()].x - polygon[i].x)
		var slope_b = (polygon[(i + 2) % polygon.size()].y - polygon[(i + 1) % polygon.size()].y) - (polygon[(i + 2) % polygon.size()].x - polygon[(i + 1) % polygon.size()].x)
		var slope_c = (polygon[(i + 3) % polygon.size()].y - polygon[(i + 2) % polygon.size()].y) - (polygon[(i + 3) % polygon.size()].x - polygon[(i + 2) % polygon.size()].x)
		if abs(slope_a - slope_b) <= max_threshold and abs(slope_b - slope_c) <= max_threshold and abs(slope_c - slope_a) <= max_threshold:
			return true
	
	return false


static func remove_far_off_points(polygon: PackedVector2Array, max_threshold: float = 0.1) -> PackedVector2Array:
	var result: PackedVector2Array
	for i in range(polygon.size()):
		var slope_a = (polygon[i].y - polygon[(i - 1) % polygon.size()].y) / (polygon[i].x - polygon[(i - 1) % polygon.size()].x)
		var slope_b = (polygon[(i + 1) % polygon.size()].y - polygon[i].y) / (polygon[(i + 1) % polygon.size()].x - polygon[i].x)
		if abs(slope_a - slope_b) >= max_threshold:
			result.append(polygon[i])
	
	return result


static func get_smallest_center_delta(polygon: PackedVector2Array) -> float:
	var result: float = 1000000.0
	
	var centers: Array[Vector2]
	for i in range(polygon.size()):
		centers.append(polygon[i].lerp(polygon[(i + 1) % polygon.size()], 0.5))
	
	for center in centers:
		for other_center in centers:
			if center == other_center:
				continue
			else:
				# TODO Look into optimization for distance check math.
				var distance = center.distance_to(other_center)
				if distance < result:
					result = distance
	
	return result


static func get_scaled_polygon(polygon: PackedVector2Array, scale: Vector2):
	var result: PackedVector2Array
	for point in polygon:
		var scaled_point = Vector2(point.x * scale.x, point.y * scale.y)
		result.append(scaled_point)
	
	return result


static func get_rotated_polygon(polygon: PackedVector2Array, angle: float):
	var result: PackedVector2Array
	for point in polygon:
		result.append(point.rotated(angle))
	
	return result


static func get_polygon_from_radius(point_count: int, radius: float) -> PackedVector2Array:
	var result: PackedVector2Array
	
	for i in range(point_count):
		var angle = deg_to_rad(i * (360.0 / float(point_count)))
		var new_point = (Vector2.UP * radius).rotated(angle)
		result.append(new_point)
	
	return result


static func get_translated_polygon(polygon: PackedVector2Array, translation: Vector2) -> PackedVector2Array:
	var result: PackedVector2Array
	
	for point in polygon:
		result.append(Vector2(point.x + translation.x, point.y + translation.y))
	
	return result
