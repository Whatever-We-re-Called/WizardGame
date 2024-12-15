class_name Perk extends Resource

enum Rarity { COMMON, UNCOMMON, RARE }

@export var name: String
@export var icon: Texture = preload("res://perks/icons/shitty_default_perk_icon.png")
@export var rarity: Rarity
@export_multiline var description: String
@export var execution_script: Script


func get_color() -> Color:
	match rarity:
		Rarity.COMMON:
			return Color.WHITE
		Rarity.UNCOMMON:
			return Color.GREEN
		Rarity.RARE:
			return Color.AQUA
		_:
			return Color.WHITE
