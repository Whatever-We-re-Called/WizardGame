class_name Intermission extends Node

enum State { START, SCORING, RESULTS, SPELLBOOK, END }

@onready var multiplayer_synchronizer: MultiplayerSynchronizer = $MultiplayerSynchronizer
@onready var start_ui: CenterContainer = %StartUI
@onready var scoring_ui: CenterContainer = %ScoringUI
@onready var results_ui: CenterContainer = %ResultsUI
@onready var spellbook_ui: CenterContainer = %SpellbookUI
@onready var end_ui: CenterContainer = %EndUI

var game_manager: GameManager
var player_perk_executions: Dictionary


func _ready():
	results_ui.continued.connect(
		func(): game_manager.game_scene.transition_to_state("waitlobby")
	)


@rpc("authority", "call_local", "reliable")
func set_state(state: State):
	start_ui.visible = (state == State.START)
	scoring_ui.visible = (state == State.SCORING)
	results_ui.visible = (state == State.RESULTS)
	spellbook_ui.visible = (state == State.SPELLBOOK)
	end_ui.visible = (state == State.END)


func add_player_perk_execution(executor_player: Player, perk: Perk):
	if player_perk_executions.has(executor_player):
		player_perk_executions[executor_player].append(perk)
	else:
		player_perk_executions[executor_player] = [perk]
