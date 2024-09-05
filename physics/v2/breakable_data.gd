class_name BreakableData extends Resource

@export var max_health: float = 10.0
@export var layer: BreakableBody2D.EnvironmentLayer = BreakableBody2D.EnvironmentLayer.BASE
@export_range(0, 200) var number_of_break_points: int = 5
