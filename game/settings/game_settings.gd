class_name GameSettings extends Resource

@export_category("Scoring")
@export var goal_score: int
@export_category("Spells")
@export var spell_pool: SpellPool
@export var default_spells_page_count: int
@export_category("Perks")
@export var perk_pool: PerkPool
@export var default_perk_choice_count: int
@export_category("Maps")
@export var map_pool: Array[PackedScene]
@export var map_disaster_severity: int
@export_category("Disasters")
@export var disaster_duration: float
@export var time_before_first_disaster: float
@export var time_inbetween_disasters: float
@export var time_after_last_disaster: float
@export var disaster_pool: Array[DisasterResource]
