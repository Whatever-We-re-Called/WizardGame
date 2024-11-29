class_name Perk extends Resource

enum Rarity { Common, Uncommon, Rare }

@export var name: String
@export var icon: Texture = preload("res://perks/icons/shitty_default_perk_icon.png")
@export var rarity: Rarity
@export_multiline var description: String
