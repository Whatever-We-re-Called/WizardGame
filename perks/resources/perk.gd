class_name Perk extends Resource

enum Rank { ONE_STAR, TWO_STAR, THREE_STAR }
enum DeactivationEvent { NONE, ON_MAP_END }
enum Character { 
	SPELLS, RUNES, HEALTH, POINTS,
	SELF_BUFFS, OPPONENT_DEBUFFS, MAP, CONTRACTS 
}

@export var character: PerkCharacter
@export var rank: Rank
@export_multiline var description: String
@export var deactivation_event: DeactivationEvent = DeactivationEvent.NONE
@export var execution_script: Script


func get_color() -> Color:
	match rank:
		Rank.ONE_STAR:
			return Color("#93ef84")
		Rank.TWO_STAR:
			return Color("#7d9bcf")
		Rank.THREE_STAR:
			return Color("#b3a3d4")
		_:
			return Color.WHITE
