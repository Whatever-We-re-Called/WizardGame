extends IntermissionUI

var other_players_data: Dictionary


func setup_on_server():
	if not multiplayer.is_server(): return
	
	for player in intermission.game_manager.players:
		_init_modifying_player_card(player)
		_init_other_players_page_progress_ui(player)


func _init_modifying_player_card(player: Player):
	# TODO Make this more dynamic.
	var perk_page_count = 1
	var perk_pages_dictionary = _get_generated_perks_dictionary(perk_page_count)
	
	var player_data: Dictionary = {
		"peer_id": player.peer_id,
		"name": player.name,
		"node_path": player.get_path(),
		"perk_pages": perk_pages_dictionary
	}
	
	_create_modifying_player_card.rpc_id(player.peer_id, player_data)


func _get_generated_perks_dictionary(perk_page_count: int) -> Dictionary:
	var result: Dictionary
	
	var perk_pool = preload("res://perks/pools/temporary_perk_pool.tres")
	for i in range(perk_page_count):
		var perk_page = i + 1
		var perks = perk_pool.get_random_perks(3, false)
		
		result[perk_page] = []
		for perk in perks:
			result[perk_page].append(perk.resource_path)
	
	return result


func _init_other_players_page_progress_ui(player: Player):
	var other_players_data: Dictionary
	for other_player in intermission.game_manager.players:
		if player != other_player:
			other_players_data[other_player.peer_id] = {
				"name": str(other_player.name)
			}
	_create_other_players_page_progress_ui.rpc_id(player.peer_id, other_players_data)


@rpc("authority", "call_local", "reliable")
func _create_modifying_player_card(player_data: Dictionary):
	for child in %SingleModifyingPlayerCardSlot.get_children():
		child.queue_free()
	
	var modifying_player_card = preload("res://game/intermission/modifying/modifying_player_card.tscn").instantiate()
	%SingleModifyingPlayerCardSlot.add_child(modifying_player_card)
	# Setup must come after ModifyingPlayerCard enters the scene
	# tree, in order to the player scene absolute path to be valid.
	modifying_player_card.setup_online(player_data)
	#modifying_player_card.page_updated.connect(_handle_page_change)


@rpc("authority", "call_local", "reliable")
func _create_other_players_page_progress_ui(other_players_data: Dictionary):
	self.other_players_data = other_players_data
	
	for other_player_data in other_players_data:
		var other_player_name = other_players_data[other_player_data]["name"]
		
		var other_player_page_progress = preload("res://game/intermission/modifying/online/online_player_page_progress_ui.tscn").instantiate()
		other_player_page_progress.setup(other_player_name)
		%OtherPlayerPageProgressContainer.add_child(other_player_page_progress)
		
		other_players_data[other_player_data]["ui_node"] = other_player_page_progress
