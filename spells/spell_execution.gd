class_name SpellExecution extends Node2D

var resource: Spell
var type: Spells.Type
var player: Player
var slot: int
var level: int:
	get():
		return player.spell_inventory.get_level(type)
	set(value):
		push_error("Cannot set level of spell directly. Use SpellInventory#add_levels")

var cooldown_timer: SceneTreeTimer

func setup(resource: Spell, type: Spells.Type, player: Player, slot: int):
	self.resource = resource
	self.type = type
	self.player = player
	self.slot = slot


func process(delta: float) -> void:
	if not player.can_use_abilities:
		return
	
	if _is_cooldown_automatically_managed() and _is_on_cooldown():
		return
	
	if Input.is_action_just_pressed(player.im.use_spell):
		if _on_button_down() and _is_cooldown_automatically_managed():
			_start_cooldown()
	if Input.is_action_just_released(player.im.use_spell):
		if _on_button_up() and _is_cooldown_automatically_managed():
			_start_cooldown()

func _get_cooldown() -> float:
	return 3.0


func _is_cooldown_automatically_managed() -> bool:
	return true


func _on_button_down() -> bool:
	return false


func _on_button_up():
	return true


func _is_on_cooldown() -> bool:
	return cooldown_timer != null and cooldown_timer.time_left > 0.0


func _start_cooldown():
	cooldown_timer = get_tree().create_timer(_get_cooldown())
	
	
func _cleanup():
	pass
	
	
func get_level():
	return level # TODO - perks
