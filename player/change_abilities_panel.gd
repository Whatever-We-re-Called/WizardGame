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
		
		option_button.item_selected.connect(_update_player_abilities)


func _update_player_abilities(index: int):
	for i in range(abilitity_option_buttons.size()):
		var option_button = abilitity_option_buttons[i]
		player.abilities[i] = option_button.selected
	
	player.update_ability_nodes.rpc()
