extends PanelContainer

@onready var abilitity_option_buttons = [
	%Ability1OptionButton,
	%Ability2OptionButton,
	%Ability3OptionButton
]

var player: Player


func setup(player: Player):
	self.player = player
	
	for i in range(abilitity_option_buttons.size()):
		var option_button = abilitity_option_buttons[i]
		for j in range(Abilities.Type.keys().size()):
			var ability_name = Abilities.Type.keys()[j]
			var ability_value = Abilities.Type.values()[j]
			
			option_button.add_item(ability_name)
			if ability_value == player.abilities[i]:
				option_button.selected = ability_value
		
		option_button.item_selected.connect(_on_item_selected)


func _on_item_selected(index: int):
	var new_abilities: Array[Abilities.Type]
	for i in range(abilitity_option_buttons.size()):
		var option_button = abilitity_option_buttons[i]
		new_abilities.append(option_button.selected)
	_update_player_abilities.rpc(new_abilities)


@rpc("any_peer", "call_local")
func _update_player_abilities(new_abilities: Array[Abilities.Type]):
	for i in range(new_abilities.size()):
		player.abilities[i] = new_abilities[i]
	
	player.clear_ability_nodes.rpc()
	player.create_ability_nodes()
