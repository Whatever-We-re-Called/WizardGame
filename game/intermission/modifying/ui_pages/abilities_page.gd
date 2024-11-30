extends VBoxContainer

var player: Player


func setup():
	self.player = player
	
	_update_current_abilities_ui()


func _update_current_abilities_ui():
	var current_ability_icons = [
		%CurrentAbility1Icon, %CurrentAbility2Icon, %CurrentAbility3Icon 
	]
	var current_ability_level_labels = [
		%CurrentAbility1LevelLabel, %CurrentAbility2LevelLabel, %CurrentAbility3LevelLabel
	]
	
	for i in range(player.abilities.size()):
		var ability_resource = Abilities.get_ability_resource(player.abilities[i])
		var current_ability_icon = current_ability_icons[i]
		var current_ability_level_label = current_ability_level_labels[i]
		
		#current_ability_icon.texture = ability_resource.
