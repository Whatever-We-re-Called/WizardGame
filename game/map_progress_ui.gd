extends CenterContainer

@onready var current_disaster_label: Label = %CurrentDisasterLabel
@onready var disaster_icons: HBoxContainer = %DisasterIcons

const DISASTER_SEVERITY_COLORS = {
	DisasterInfo.Severity.LOW: Color.GREEN,
	DisasterInfo.Severity.MEDIUM: Color.YELLOW,
	DisasterInfo.Severity.HIGH: Color.RED,
	DisasterInfo.Severity.VERY_HIGH: Color.DARK_RED,
}
const DISASTER_SELECT_COLOR = Color.WHITE
const DISASTER_GRAYED_COLOR = Color.WEB_GRAY
const UNKNOWN_DISASTER_TEXTURE = preload("res://disasters/textures/icons/shitty_hidden_disaster_icon.png")


@rpc("any_peer", "call_local")
func set_countdown_to_disaster_text(countdown: int, is_first: bool):
	current_disaster_label.label_settings.font_color = Color.WHITE
	if is_first == true:
		current_disaster_label.text = "First disaster starting in " + str(countdown) + "s"
	else:
		current_disaster_label.text = "Next disaster starting in " + str(countdown) + "s"


@rpc("any_peer", "call_local")
func set_countdown_to_intermission_text(countdown: int):
	current_disaster_label.label_settings.font_color = Color.WHITE
	current_disaster_label.text = "Switching maps in " + str(countdown) + "s"


@rpc("any_peer", "call_local")
func set_current_disaster_text(disaster: DisasterInfo):
	current_disaster_label.label_settings.font_color = DISASTER_SEVERITY_COLORS[disaster.severity]
	current_disaster_label.text = "Current Disaster: " + disaster.display_name


@rpc("any_peer", "call_local")
func update_disaster_icons(disasters: Array[DisasterInfo], current_disaster_number: int, revealed: bool):
	for child in disaster_icons.get_children():
		child.queue_free()
	
	for i in range(disasters.size()):
		var disaster = disasters[i]
		var index_disaster_number = i + 1
		
		var texture_rect = TextureRect.new()
		texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		texture_rect.custom_minimum_size = Vector2(64, 64)
		texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		
		if index_disaster_number < current_disaster_number:
			texture_rect.texture = disaster.icon_texture
			texture_rect.self_modulate = DISASTER_GRAYED_COLOR
			texture_rect.custom_minimum_size = Vector2(48, 48)
		elif index_disaster_number == current_disaster_number:
			if revealed:
				texture_rect.texture = disaster.icon_texture
				texture_rect.self_modulate = DISASTER_SEVERITY_COLORS[disaster.severity]
			else:
				texture_rect.texture = UNKNOWN_DISASTER_TEXTURE
				texture_rect.self_modulate = DISASTER_SELECT_COLOR
			texture_rect.custom_minimum_size = Vector2(64, 64)
		else:
			texture_rect.texture = UNKNOWN_DISASTER_TEXTURE
			texture_rect.self_modulate = DISASTER_GRAYED_COLOR
			texture_rect.custom_minimum_size = Vector2(48, 48)
		
		disaster_icons.add_child(texture_rect)
