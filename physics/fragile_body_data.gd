class_name FragileBodyData extends Resource

enum EnvironmentLayer { FRONT, BASE, BACK }

@export var max_health: float = 10.0
@export var layer: EnvironmentLayer = EnvironmentLayer.BASE
@export_range(0, 200) var number_of_break_points: int = 5
@export var edge_threshold: float = 10.0
@export var length_limit: float = 20
