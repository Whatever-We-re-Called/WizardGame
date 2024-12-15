class_name PerkData extends Resource

@export_group("Perk Pools")
@export var distance_perk_pools: Array[PerkPool]
@export_subgroup("Debug")
@export var use_debug_perk_pool: bool = false
@export var debug_perk_pool: PerkPool
@export_group("Execution Values")
@export var map_disaster_severity_increase_amount: int = 0
