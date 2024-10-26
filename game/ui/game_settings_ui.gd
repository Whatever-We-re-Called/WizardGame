extends CenterContainer

signal closed

@onready var survival_goals_line_edit: LineEdit = %SurvivalGoalsLineEdit
@onready var map_disaster_severity_line_edit: LineEdit = %MapDisasterSeverityLineEdit
@onready var disaster_duration_line_edit: LineEdit = %DisasterDurationLineEdit
@onready var time_before_first_disaster_line_edit: LineEdit = %TimeBeforeFirstDisasterLineEdit
@onready var time_inbetween_disasters_line_edit: LineEdit = %TimeInbetweenDisastersLineEdit
@onready var time_after_last_disaster_line_edit: LineEdit = %TimeAfterLastDisasterLineEdit

var saved_game_settings: GameSettings


func populate(game_settings: GameSettings):
	self.saved_game_settings = game_settings
	
	survival_goals_line_edit.text = str(game_settings.survivals_goal)
	
	map_disaster_severity_line_edit.text = str(game_settings.map_disaster_severity)
	
	disaster_duration_line_edit.text = str(game_settings.disaster_duration)
	time_before_first_disaster_line_edit.text = str(game_settings.time_before_first_disaster)
	time_inbetween_disasters_line_edit.text = str(game_settings.time_inbetween_disasters)
	time_after_last_disaster_line_edit.text = str(game_settings.time_after_last_disaster)


func get_game_settings() -> GameSettings:
	var game_settings = GameSettings.new()
	
	game_settings.survivals_goal = float(survival_goals_line_edit.text)
	
	game_settings.map_disaster_severity = float(map_disaster_severity_line_edit.text)
	game_settings.map_pool = saved_game_settings.map_pool.duplicate()
	
	game_settings.disaster_duration = float(disaster_duration_line_edit.text)
	game_settings.time_before_first_disaster = float(time_before_first_disaster_line_edit.text)
	game_settings.time_inbetween_disasters = float(time_inbetween_disasters_line_edit.text)
	game_settings.time_after_last_disaster = float(time_after_last_disaster_line_edit.text)
	game_settings.disaster_pool = saved_game_settings.disaster_pool.duplicate()
	
	return game_settings


func _on_save_and_close_button_pressed() -> void:
	closed.emit()
