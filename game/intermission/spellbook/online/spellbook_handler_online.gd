extends Node

var spellbook_ui: IntermissionUI
var players: Array[Player]
var player_data: Dictionary


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
	spellbook_ui.spellbook.setup(player_data)


func start_sequence_for_player(player_peer_id: int):
	var perk_page_count = 2
	while perk_page_count > 0:
		var perk_resources = _get_generated_perk_resources()
		_load_perk_page.rpc_id(player_peer_id, perk_resources)
		perk_page_count -= 1
		return


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
	
	spellbook_ui.spellbook.load_perk_page(perks)
