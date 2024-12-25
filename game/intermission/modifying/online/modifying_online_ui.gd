extends IntermissionUI

signal all_players_readied

var player_data: Dictionary
var other_players_data: Dictionary
var readied_players: Array[int]


func setup_on_server():
	if not multiplayer.is_server(): return
	
	for player in intermission.game_manager.players:
		_init_modifying_player_card(player)
		_init_other_players_page_progress_ui(player)


func _init_modifying_player_card(player: Player):
	var perk_page_count = intermission.game_manager.perks_manager.get_player_perk_choice_count(player)
	var perk_pages_dictionary = _get_generated_perks_dictionary(player, perk_page_count)
	var spell_page_count = _get_spell_page_count(player)
	var spell_pages_dictionary = _get_spell_pages_dictionary(player, spell_page_count)
	player.spell_inventory.set_spell_page_count(0)
	
	var created_player_data: Dictionary = {
		"peer_id": player.peer_id,
		"name": player.get_display_name(),
		"node_path": player.get_path(),
		"perk_pages": perk_pages_dictionary,
		"spell_pages": spell_pages_dictionary
	}
	
	_create_modifying_player_card.rpc_id(player.peer_id, created_player_data)


func _get_generated_perks_dictionary(player: Player, perk_page_count: int) -> Dictionary:
	var result: Dictionary
	
	var perk_pool = intermission.game_manager.game_settings.perk_pool
	for i in range(perk_page_count):
		var perk_page = i + 1
		var perks = perk_pool.get_random_perks(3, false)
		
		result[perk_page] = []
		for perk in perks:
			result[perk_page].append(perk.resource_path)
	
	return result


func _get_spell_page_count(player: Player) -> int:
	var default_spell_page_count = intermission.game_manager.game_settings.default_spell_page_count
	var player_spell_page_count = player.spell_inventory.spell_page_count
	return default_spell_page_count + player_spell_page_count


func _get_spell_pages_dictionary(player: Player, spell_page_count: int) -> Dictionary:
	var result: Dictionary
	
	var spell_pool = intermission.game_manager.game_settings.spell_pool
	for i in range(spell_page_count):
		var spell_page = i + 1
		var spell_types = spell_pool.get_lacking_random_spells(3, player)
		
		result[spell_page] = []
		for spell_type in spell_types:
			result[spell_page].append(spell_type)
	
	return result


func _init_other_players_page_progress_ui(player: Player):
	var other_players_data: Dictionary
	for other_player in intermission.game_manager.players:
		if player != other_player:
			other_players_data[other_player.peer_id] = {
				"peer_id": other_player.peer_id,
				"name": str(other_player.name)
			}
	_create_other_players_page_progress_ui.rpc_id(player.peer_id, other_players_data)


@rpc("authority", "call_local", "reliable")
func _create_modifying_player_card(player_data: Dictionary):
	self.player_data = player_data
	
	for child in %SingleModifyingPlayerCardSlot.get_children():
		child.queue_free()
	
	var modifying_player_card = preload("res://game/intermission/modifying/modifying_player_card.tscn").instantiate()
	%SingleModifyingPlayerCardSlot.add_child(modifying_player_card)
	# Setup must come after ModifyingPlayerCard enters the scene
	# tree, in order to the player scene absolute path to be valid.
	modifying_player_card.setup_online(player_data)
	modifying_player_card.page_updated.connect(_handle_page_change)
	modifying_player_card.perk_obtained.connect(_handle_perk_obtained.bind(player_data))
	modifying_player_card.spell_obtained.connect(_handle_spell_obtained.bind(player_data))


func _handle_page_change(current_page: int, max_page: int):
	for other_player_data in other_players_data:
		var peer_id = other_players_data[other_player_data]["peer_id"]
		
		_update_other_player_page_progress_ui.rpc_id(
			peer_id,
			player_data["peer_id"],
			current_page,
			max_page
		)
	
	if max_page == current_page:
		_ready_player_on_server.rpc_id(1, player_data["peer_id"])
	else:
		_unready_player_on_server.rpc_id(1, player_data["peer_id"])


func _handle_perk_obtained(perk_resource_path: String, player_data: Dictionary):
	_handle_perk_obtained_on_server.rpc_id(1, perk_resource_path, player_data["peer_id"])


@rpc("any_peer", "call_local", "reliable")
func _handle_perk_obtained_on_server(perk_resource_path: String, executor_peer_id: int):
	var executor_player = intermission.game_manager.get_player_from_peer_id(executor_peer_id)
	intermission.game_manager.perks_manager.execute_perk(
		load(perk_resource_path), executor_player
	)


func _handle_spell_obtained(spell_type: Spells.Type, player_data: Dictionary):
	print("Test")
	_handle_spell_obtained_on_server.rpc_id(1, spell_type, player_data["peer_id"])


@rpc("any_peer", "call_local", "reliable")
func _handle_spell_obtained_on_server(spell_type: Spells.Type, executor_peer_id: int):
	var executor_player = intermission.game_manager.get_player_from_peer_id(executor_peer_id)
	executor_player.spell_inventory.set_level.rpc(spell_type, 1)


@rpc("authority", "call_local", "reliable")
func _create_other_players_page_progress_ui(other_players_data: Dictionary):
	self.other_players_data = other_players_data
	
	for other_player_data in other_players_data:
		var other_player_name = other_players_data[other_player_data]["name"]
		
		var other_player_page_progress = preload("res://game/intermission/modifying/online/other_player_page_progress_ui.tscn").instantiate()
		other_player_page_progress.setup(other_player_name)
		%OtherPlayerPageProgressContainer.add_child(other_player_page_progress)
		
		other_players_data[other_player_data]["ui_node"] = other_player_page_progress


@rpc("any_peer", "call_local", "reliable")
func _update_other_player_page_progress_ui(other_player_peer_id: int, current_page: int, max_page: int):
	for other_player_data in other_players_data:
		var peer_id = other_players_data[other_player_data]["peer_id"]
		if peer_id == other_player_peer_id:
			var ui_node = other_players_data[other_player_data]["ui_node"]
			ui_node.update(current_page, max_page)


@rpc("any_peer", "call_local", "reliable")
func _ready_player_on_server(player_peer_id: int):
	if not readied_players.has(player_peer_id):
		readied_players.append(player_peer_id)
	
	var total_player_count = other_players_data.size() + 1
	if readied_players.size() == total_player_count:
		all_players_readied.emit()


@rpc("any_peer", "call_local", "reliable")
func _unready_player_on_server(player_peer_id: int):
	if readied_players.has(player_peer_id):
		readied_players.erase(player_peer_id)
