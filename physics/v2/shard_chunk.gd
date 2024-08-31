class_name ShardChunk extends BreakableBody2D


func _ready() -> void:
	update_physics_layer()
	create_shard_polygons()
