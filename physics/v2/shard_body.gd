class_name ShardBody extends BreakableBody2D


func _ready() -> void:
	freeze = true
	update_physics_layer()
	create_shard_polygons()
