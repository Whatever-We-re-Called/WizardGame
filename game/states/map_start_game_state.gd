extends GameState


func _enter():
	game_scene.load_random_map.rpc_id(1)
	
	game_scene.current_disaster_number = 1
	_populate_current_map_disasters()
	
	game_scene.map_progress_ui.visible = true
	
	await get_tree().process_frame
	game_scene.transition_to_state("disasterstart")


func _populate_current_map_disasters():
	game_scene.current_map_disasters.clear()
	
	var current_severity = 0
	var target_severity = game_scene.game_manager.game_settings.map_disaster_severity
	while true:
		randomize()
		var disaster_pool_copy = game_scene.game_manager.game_settings.disaster_pool.duplicate()
		disaster_pool_copy.shuffle()
		
		var added_at_least_one = false
		for disaster in disaster_pool_copy:
			var added_severity = int(disaster.severity) + 1
			
			if (current_severity + added_severity) <= target_severity:
				game_scene.current_map_disasters.append(disaster)
				current_severity += added_severity
				added_at_least_one = true
		
		if current_severity >= target_severity:
			break
		elif added_at_least_one == false:
			break
	
	randomize()
	game_scene.current_map_disasters.shuffle()
