class_name ShardDropThroughCollision extends CollisionPolygon2D


func _ready() -> void:
	one_way_collision = true
	var static_body = AnimatableBody2D.new()
	add_sibling.call_deferred(static_body)
	reparent.call_deferred(static_body)


func _process(delta: float) -> void:
	pass
