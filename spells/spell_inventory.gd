extends Node
class_name SpellInventory

@onready var spell_nodes: Node = %SpellNodes
var equipped_spells: Array[Node2D] = []
var equipped_spell_types: Array[Spells.Type]:
	get():
		var arr: Array[Spells.Type] = []
		for spell in equipped_spells:
			arr.append(spell.type)
		return arr

var levels = {}
var temporary_levels = {}


func _get_player() -> Player:
	return get_parent();


# TODO - we may want to rework this based on the configured starting spells from game settings
# I'm not sure how that system will work so leaving this as a TODO
func init_starting_spells(spells_config: Dictionary):
	var slot = 0
	for type in spells_config.keys():
		var level = spells_config[type]
		set_level.rpc(type, level)
		add_levels(level, type)
		set_spell_slot(slot, type)
		slot += 1


@rpc("any_peer", "call_local", "reliable")
func set_spell_slot(slot: int, type: int):
	if equipped_spells.size() > slot:
		equipped_spells[slot]._cleanup()
		equipped_spells[slot].free()
	
	var spell_node = Spells.create_node_for_rpc(type, _get_player(), slot)
	spell_nodes.add_child(spell_node, true)
	if equipped_spells.size() == slot:
		equipped_spells.append(spell_node)
	else:
		equipped_spells[slot] = spell_node


@rpc("any_peer", "call_local", "reliable")
func clear_spell_nodes():
	for child in spell_nodes.get_children():
		child.queue_free()
	equipped_spells.clear()
	
	
func has(type: Spells.Type) -> bool:
	return levels.has(type)
	
	
func get_level(type: Spells.Type) -> int:
	var level = 0
	if levels.has(type):
		level = max(1, levels.get(type))
	if temporary_levels.has(type):
		level = max(1, level + temporary_levels[type])
	return level
	

func get_true_level(type: Spells.Type) -> int:
	var level = 0
	if levels.has(type):
		level = levels.get(type)
	if temporary_levels.has(type):
		level += temporary_levels[type]
	return level
	
	
func inc_level(type: Spells.Type):
	add_levels(1, type)
	
	
func add_levels(amount: int, type: Spells.Type):
	_add_levels.rpc(amount, type)
	
	
@rpc("any_peer", "call_local", "reliable")
func _add_levels(amount: int, type: Spells.Type):
	var level = levels.get_or_add(type, 0)
	level += amount
	levels[type] = min(level, Spells.get_spell_resource(type).max_level)


func dec_level(type: Spells.Type):
	remove_levels(1, type)
	
	
func remove_levels(amount: int, type: Spells.Type):
	_remove_levels.rpc(amount, type)
	
	
@rpc("any_peer", "call_local", "reliable")
func _remove_levels(amount: int, type: Spells.Type):
	var level = levels.get_or_add(type, 0)
	level -= amount
	levels[type] = max(0, level)
	
	if levels[type] == 0:
		levels.erase(type)


func remove_spell(type: Spells.Type):
	_remove_spell.rpc(type)
	
	
@rpc("any_peer", "call_local", "reliable")
func _remove_spell(type: Spells.Type):
	levels.erase(type)
	temporary_levels.erase(type)
	
	
func clear():
	_clear.rpc()
	
	
@rpc("any_peer", "call_local", "reliable")
func _clear():
	levels.clear()
	temporary_levels.clear()
	
	
func clear_all_temporary_levels():
	_clear_all_temporary_levels.rpc()
	
	
@rpc("any_peer", "call_local", "reliable")
func _clear_all_temporary_levels():
	temporary_levels.clear()
	
	
func add_temporary_levels(amount: int, type: Spells.Type):
	_add_temporary_levels.rpc(amount, type)
	
	
func remove_temporary_levels(amount: int, type: Spells.Type):
	_remove_temporary_levels.rpc(amount, type)
	
	
@rpc("any_peer", "call_local", "reliable")
func _add_temporary_levels(amount: int, type: Spells.Type):
	var level = temporary_levels.get_or_add(type, 0)
	temporary_levels[type] = level + amount
	
	
@rpc("any_peer", "call_local", "reliable")
func _remove_temporary_levels(amount: int, type: Spells.Type):
	var level = temporary_levels.get_or_add(type, 0)
	temporary_levels[type] = level - amount
	
	
@rpc("any_peer", "reliable") # Purposefully no call_local, used via sync
func set_level(type: Spells.Type, level: int):
	levels[type] = level
	
	
@rpc("any_peer", "reliable") # Purposefully no call_local, used via sync
func set_temporary_level(type: Spells.Type, level: int):
	temporary_levels[type] = level
	
	
@rpc("any_peer", "reliable")
func sync(peer_id):
	for type in levels.keys():
		set_level.rpc_id(peer_id, type, levels[type])
	for type in temporary_levels.keys():
		set_temporary_level.rpc_id(peer_id, type, temporary_levels[type])
	
	
	
