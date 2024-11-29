extends IntermissionUI


func setup_on_server():
	if not multiplayer.is_server(): return
	
	for player in intermission.game_manager.players:
		# TODO Make this more dynamic.
		var perk_page_count = 1
		
		var perk_pages_dictionary = _get_generated_perks_dictionary(perk_page_count)
		_create_modifying_player_card.rpc_id(player.peer_id, perk_pages_dictionary)


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


@rpc("authority", "call_local", "reliable")
func _create_modifying_player_card(perk_pages_dictionary: Dictionary):
	for child in %SingleModifyingPlayerCardSlot.get_children():
		child.queue_free()
	
	var modifying_player_card = preload("res://game/intermission/modifying/modifying_player_card.tscn").instantiate()
	modifying_player_card.setup(perk_pages_dictionary)
	%SingleModifyingPlayerCardSlot.add_child(modifying_player_card)
