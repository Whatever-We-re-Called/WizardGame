extends Node

var spellbook_ui: IntermissionUI
var players: Array[Player]
var player_data: Dictionary
var other_players_data: Dictionary
var player_sequence_continue_signals: Dictionary
var player_perk_page_counts: Dictionary
var player_spell_page_counts: Dictionary
var readied_player_peer_ids: Array[int]
var player_current_pages: Dictionary
var player_max_pages: Dictionary


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


func init_all_other_players_page_progress_ui():
	for player in players:
		var other_players_data: Dictionary
		for other_player in players:
			if player != other_player:
				other_players_data[other_player.peer_id] = {
					"peer_id": other_player.peer_id,
					"name": other_player.get_display_name()
				}
		
		_set_other_players_data.rpc_id(player.peer_id, other_players_data)
		spellbook_ui.spellbook.create_other_players_page_progress_ui.rpc_id(player.peer_id, other_players_data)


@rpc("authority", "call_local", "reliable")
func _set_other_players_data(other_players_data: Dictionary):
	self.other_players_data = other_players_data


# Executed solely on the server, once for each player
func start_sequence_for_player(player: Player):
	var signal_name = "peer_id_%s_sequence_continued" % [player.peer_id]
	player_sequence_continue_signals[player.peer_id] = Signal(self, signal_name)
	add_user_signal(signal_name)
	
	player_perk_page_counts[player.peer_id] = _get_perk_page_count(player)
	player_spell_page_counts[player.peer_id] = _get_spell_page_count(player)
	player.spell_inventory.set_extra_spell_page_count(0)
	
	player_current_pages[player.peer_id] = 1
	player_max_pages[player.peer_id] = player_perk_page_counts[player.peer_id]\
		+ player_spell_page_counts[player.peer_id]\
		+ 2
	
	while player_perk_page_counts[player.peer_id] > 0:
		player_perk_page_counts[player.peer_id] -= 1
		
		var perk_resources = _get_generated_perk_resources()
		_load_perk_page.rpc_id(player.peer_id, perk_resources)
		
		await player_sequence_continue_signals[player.peer_id]
	
	while player_spell_page_counts[player.peer_id] > 0:
		player_spell_page_counts[player.peer_id] -= 1
		
		var spell_types = _get_generated_spell_types(player)
		_load_spell_page.rpc_id(player.peer_id, spell_types)
		
		await player_sequence_continue_signals[player.peer_id]
	
	_load_inventory_page.rpc_id(player.peer_id)


@rpc("any_peer", "call_local", "reliable")
func _continue_sequence(player_peer_id: int):
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
			_handle_chosen_perk.rpc_id(1, player_data["peer_id"], perk_resource_path)
			_continue_sequence.rpc_id(1, player_data["peer_id"])
	)
	
	_update_page_progress_ui(1, 4)


@rpc("any_peer", "call_local", "reliable")
func _handle_chosen_perk(peer_id: int, perk_resource_path: String):
	var perk = load(perk_resource_path)
	var player = spellbook_ui.intermission.game_manager.get_player_from_peer_id(peer_id)
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
			_handle_chosen_spell.rpc_id(1, player_data["peer_id"], spell_type)
			_continue_sequence.rpc_id(1, player_data["peer_id"])
	)
	
	_update_page_progress_ui(2, 4)


@rpc("any_peer", "call_local", "reliable")
func _handle_chosen_spell(peer_id: int, spell_type: Spells.Type):
	var player = spellbook_ui.intermission.game_manager.get_player_from_peer_id(peer_id)
	player.spell_inventory.set_level.rpc(spell_type, 1)


@rpc("authority", "call_local", "reliable")
func _load_inventory_page():
	spellbook_ui.spellbook.load_inventory_page(
		get_node(player_data["node_path"]),
		func():
			_ready_player_peer_id.rpc_id(1, player_data["peer_id"])
	)
	
	_update_page_progress_ui(3, 4)


@rpc("authority", "call_local", "reliable")
func _load_ready_page():
	spellbook_ui.spellbook.load_ready_page(
		func():
			_unready_player_peer_id.rpc_id(1, player_data["peer_id"])
	)
	
	_update_page_progress_ui(4, 4)


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


func _update_page_progress_ui(current_page: int, max_page: int):
	spellbook_ui.spellbook.update_page_progress_ui(current_page, max_page)
	#for other_player_data in other_players_data:
		#var peer_id = other_players_data[other_player_data]["peer_id"]
		#
		#_update_other_player_page_progress_ui.rpc_id(
			#peer_id,
			#player_data["peer_id"],
			#current_page,
			#max_page
		#)


@rpc("authority", "call_local", "reliable")
func _update_other_player_page_progress_ui(other_player_peer_id: int, current_page: int, max_page: int):
	for other_player_data in other_players_data:
		var peer_id = other_players_data[other_player_data]["peer_id"]
		
		_update_other_player_page_progress_ui.rpc_id(
			peer_id,
			player_data["peer_id"],
			current_page,
			max_page
		)
	for other_player_data in other_players_data:
		var peer_id = other_players_data[other_player_data]["peer_id"]
		if peer_id == other_player_peer_id:
			var ui_node = other_players_data[other_player_data]["ui_node"]
			ui_node.update(current_page, max_page)
