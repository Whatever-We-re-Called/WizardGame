extends Node

var spellbook_ui: IntermissionUI
var players: Array[Player]
var player_data: Dictionary
var player_sequence_continue_signals: Dictionary
var player_perk_page_counts: Dictionary
var player_spell_page_counts: Dictionary
var readied_player_peer_ids: Array[int]


func init_all_ui_data():
	for player in players:
		var player_data: Dictionary = {
			"peer_id": player.peer_id,
			"name": player.get_display_name(),
			"node_path": player.get_path()
		}
		
		_init_ui_data.rpc_id(player.peer_id, player_data)


@rpc("authority", "call_local", "reliable")
func _init_ui_data(player_data: Dictionary):
	self.player_data = player_data
	spellbook_ui.spellbook.setup(player_data)


# Executed solely on the server, once for each player
func start_sequence_for_player(player: Player):
	var signal_name = "peer_id_%s_sequence_continued" % [player.peer_id]
	player_sequence_continue_signals[player.peer_id] = Signal(self, signal_name)
	add_user_signal(signal_name)
	
	player_perk_page_counts[player.peer_id] = _get_perk_page_count(player)
	while player_perk_page_counts[player.peer_id] > 0:
		player_perk_page_counts[player.peer_id] -= 1
		
		var perk_resources = _get_generated_perk_resources()
		_load_perk_page.rpc_id(player.peer_id, perk_resources)
		
		await player_sequence_continue_signals[player.peer_id]
	
	player_spell_page_counts[player.peer_id] = _get_spell_page_count(player)
	player.spell_inventory.set_extra_spell_page_count(0)
	while player_spell_page_counts[player.peer_id] > 0:
		player_spell_page_counts[player.peer_id] -= 1
		
		var spell_types = _get_generated_spell_types(player)
		_load_spell_page.rpc_id(player.peer_id, spell_types)
		
		await player_sequence_continue_signals[player.peer_id]
	
	_load_inventory_page.rpc_id(player.peer_id)


@rpc("any_peer", "call_local", "reliable")
func continue_sequence(player_peer_id: int):
	player_sequence_continue_signals[player_peer_id].emit()


func _get_perk_page_count(player: Player):
	return spellbook_ui.intermission.game_manager.perks_manager.get_player_perk_choice_count(player)


func _get_generated_perk_resources() -> Array[String]:
	var perks = spellbook_ui.intermission.game_manager.game_settings.perk_pool.get_random_perks(3, false)
	
	var perk_resources: Array[String]
	for perk in perks:
		perk_resources.append(perk.resource_path)
	
	return perk_resources


@rpc("authority", "call_local", "reliable")
func _load_perk_page(perk_resources: Array[String]):
	var perks: Array[Perk]
	for perk_resource in perk_resources:
		perks.append(load(perk_resource))
	
	spellbook_ui.spellbook.load_perk_page(
		perks,
		func(perk_resource_path: String):
			_handle_chosen_perk.rpc_id(1, perk_resource_path)
			continue_sequence.rpc_id(1, player_data["peer_id"])
	)


@rpc("authority", "call_local", "reliable")
func _handle_chosen_perk(perk_resource_path: String):
	var perk = load(perk_resource_path)
	var player = get_node(player_data["node_path"])
	spellbook_ui.intermission.game_manager.perks_manager.execute_perk(perk, player)


func _get_spell_page_count(player: Player):
	var default_spell_page_count = spellbook_ui.intermission.game_manager.game_settings.default_spell_page_count
	var player_extra_spell_page_count = player.spell_inventory.extra_spell_page_count
	return default_spell_page_count + player_extra_spell_page_count


func _get_generated_spell_types(player: Player) -> Array[Spells.Type]:
	return spellbook_ui.intermission.game_manager.game_settings.spell_pool.get_lacking_random_spells(3, player)


@rpc("authority", "call_local", "reliable")
func _load_spell_page(spell_types: Array[Spells.Type]):
	spellbook_ui.spellbook.load_spell_page(
		spell_types,
		func(spell_type: Spells.Type):
			_handle_chosen_spell.rpc_id(1, spell_type)
			continue_sequence.rpc_id(1, player_data["peer_id"])
	)


@rpc("authority", "call_local", "reliable")
func _handle_chosen_spell(spell_type: Spells.Type):
	var player = get_node(player_data["node_path"])
	player.spell_inventory.set_level.rpc(spell_type, 1)


@rpc("authority", "call_local", "reliable")
func _load_inventory_page():
	spellbook_ui.spellbook.load_inventory_page(
		get_node(player_data["node_path"]),
		func():
			_ready_player_peer_id.rpc_id(1, player_data["peer_id"])
	)


@rpc("authority", "call_local", "reliable")
func _load_ready_page():
	spellbook_ui.spellbook.load_ready_page(
		func():
			_unready_player_peer_id.rpc_id(1, player_data["peer_id"])
	)


@rpc("any_peer", "call_local", "reliable")
func _ready_player_peer_id(peer_id: int):
	if not readied_player_peer_ids.has(peer_id):
		readied_player_peer_ids.append(peer_id)
	
	if readied_player_peer_ids.size() == spellbook_ui.intermission.game_manager.players.size():
		spellbook_ui.all_players_readied.emit()
	else:
		_load_ready_page.rpc_id(peer_id)


@rpc("any_peer", "call_local", "reliable")
func _unready_player_peer_id(peer_id: int):
	if readied_player_peer_ids.has(peer_id):
		readied_player_peer_ids.erase(peer_id)
	
	_load_inventory_page.rpc_id(peer_id)
