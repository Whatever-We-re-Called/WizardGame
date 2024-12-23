class_name Perk extends Resource

enum Rarity { COMMON, RARE, EPIC, LEGENDARY }
enum DeactivationEvent { NONE, ON_MAP_END }

@export var name: String
@export var icon: Texture = preload("res://perks/icons/shitty_default_perk_icon.png")
@export var rarity: Rarity
@export_multiline var description: String
@export var deactivation_event: DeactivationEvent = DeactivationEvent.NONE
@export var execution_script: Script


func get_color() -> Color:
	match rarity:
		Rarity.COMMON:
			return Color.LIME_GREEN
		Rarity.RARE:
			return Color.DEEP_SKY_BLUE
		Rarity.EPIC:
			return Color.MEDIUM_PURPLE
		Rarity.LEGENDARY:
			return Color.ORANGE
		_:
			return Color.WHITE
