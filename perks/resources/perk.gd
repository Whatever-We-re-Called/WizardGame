class_name Perk extends Resource

enum Rarity { Common, Uncommon, Rare }

@export var name: String
@export var icon: Texture = preload("res://perks/icons/shitty_default_perk_icon.png")
@export var rarity: Rarity
@export_multiline var description: String


func get_color() -> Color:
	match rarity:
		Rarity.Common:
			return Color.WHITE
		Rarity.Uncommon:
			return Color.GREEN
		Rarity.Rare:
			return Color.AQUA
		_:
			return Color.WHITE
