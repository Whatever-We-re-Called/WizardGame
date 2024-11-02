class_name ShardBody extends BreakableBody2D


func _ready() -> void:
	_on_creation()


func _on_creation() -> void:
	_init_texture_info()
	freeze = true
	create_fragment_polygons()
