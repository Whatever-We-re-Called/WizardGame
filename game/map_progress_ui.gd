extends CenterContainer

@onready var current_disaster_label: Label = %CurrentDisasterLabel
@onready var current_map_progress_bar: ProgressBar = %CurrentMapProgressBar

const DISASTER_SEVERITY_PRIMARY_COLORS = {
	DisasterInfo.Severity.LOW: Color.GREEN,
	DisasterInfo.Severity.MEDIUM: Color.YELLOW,
	DisasterInfo.Severity.HIGH: Color.RED,
	DisasterInfo.Severity.VERY_HIGH: Color.DARK_RED,
}
const DISASTER_SEVERITY_SECONDARY_COLOR = Color.SLATE_GRAY


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func init_progress_bar(chosen_disasters: Array[DisasterInfo], disaster_duration: float, time_inbetween_disasters: float):
	var total_time: float = 0.0
	var time_points: Dictionary = {}
	
	total_time += time_inbetween_disasters
	for disaster_info in chosen_disasters:
		time_points[total_time] = DISASTER_SEVERITY_PRIMARY_COLORS[disaster_info.severity]
		total_time += disaster_duration
		time_points[total_time] = DISASTER_SEVERITY_SECONDARY_COLOR
		total_time += time_inbetween_disasters
	
	for time_point in time_points:
		var color = time_points[time_point]
		var color_rect = ColorRect.new()
		color_rect.color = color
		color_rect.size = Vector2(16, 16)
		current_map_progress_bar.add_child(color_rect)
		
		var t = (time_point / total_time) * current_map_progress_bar.custom_minimum_size.x
		color_rect.position.x = t - 8.0
