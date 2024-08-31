class_name ShardChunk extends BreakableBody2D


func _ready() -> void:
	update_physics_layer()
	create_shard_polygons()


func _physics_process(delta: float) -> void:
	velocity.y += 9.81
	move_and_slide()
