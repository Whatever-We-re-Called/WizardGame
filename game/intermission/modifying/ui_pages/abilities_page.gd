extends VBoxContainer

signal readied

var player: Player


func setup(player: Player):
	self.player = player
	
	_update_current_abilities_ui()


func _update_current_abilities_ui():
	# TODO Waiting for ability inventory and levels.
	pass
	
	#var current_ability_icons = [
		#%CurrentAbility1Icon, %CurrentAbility2Icon, %CurrentAbility3Icon 
	#]
	#var current_ability_level_labels = [
		#%CurrentAbility1LevelLabel, %CurrentAbility2LevelLabel, %CurrentAbility3LevelLabel
	#]
	#
	#for i in range(player.ability_types.size()):
		#var ability_type = player.ability_types[i]
		#var current_ability_icon = current_ability_icons[i]
		#var current_ability_level_label = current_ability_level_labels[i]
		#
		#if ability_type != Abilities.Type.NONE:
			#var ability_resource = Abilities.get_ability_resource(ability_type)
			#current_ability_icon.texture = ability_resource.icon_texture
			##current_ability_icon.texture = ability_resource.icon_texture
			#pass
		#else:
			#pass


func _on_ready_button_pressed() -> void:
	readied.emit()
