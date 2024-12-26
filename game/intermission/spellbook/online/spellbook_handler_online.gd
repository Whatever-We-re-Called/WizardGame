extends Node

var spellbook_ui: IntermissionUI
var players: Array[Player]
var player_data: Dictionary
var perk_page_count: int
var player_sequence_continue_signals: Dictionary


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
	
	perk_page_count = _get_perk_page_count(player)
	while perk_page_count > 0:
		perk_page_count -= 1
		
		var perk_resources = _get_generated_perk_resources()
		_load_perk_page.rpc_id(player.peer_id, perk_resources)
		
		await player_sequence_continue_signals[player.peer_id]


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
func _handle_chosen_perk(perk_resource_path):
	var perk = load(perk_resource_path)
	var player = get_node(player_data["node_path"])
	spellbook_ui.intermission.game_manager.perks_manager.execute_perk(perk, player)
