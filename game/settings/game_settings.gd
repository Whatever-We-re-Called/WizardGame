class_name GameSettings extends Resource

@export_category("General")
@export var survivals_goal: int
@export_category("Maps")
@export var map_pool: Array[PackedScene]
@export var map_disaster_severity: int
@export_category("Disasters")
@export var disaster_duration: float
@export var time_inbetween_disasters: float
@export var disaster_pool: Array[DisasterInfo]
