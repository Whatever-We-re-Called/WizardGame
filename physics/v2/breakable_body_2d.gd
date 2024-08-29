class_name BreakableBody2D extends CharacterBody2D

@export var data: BreakableData

const EDGE_THRESHOLD: float = 10.0
const LENGTH_LIMIT: float = 20.0


func _ready() -> void:
	PhysicsUtil.place_onto_environment_layer(self, data.layer, true)
