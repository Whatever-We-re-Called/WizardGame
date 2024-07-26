class_name Player extends CharacterBody2D

@export var abilities: Array[Ability]
@export var controller: PlayerController

@onready var center_point = %CenterPoint

var im: DeviceInputMap
var selected_ability_slot: int = 1


func _input(event):
	if event.is_action_pressed("use_ability"):
		_use_selected_ability()
	if event.is_action_pressed("choose_ability_slot_1"):
		_switch_to_ability_slot(1)
	if event.is_action_pressed("choose_ability_slot_2"):
		_switch_to_ability_slot(2)
	if event.is_action_pressed("choose_ability_slot_3"):
		_switch_to_ability_slot(3)
	if Input.is_action_pressed("reload_scene"):
		get_tree().reload_current_scene()


func _use_selected_ability():
	var current_selected_ability = abilities[selected_ability_slot - 1]
	AbilityExecution.try_to_execute(current_selected_ability, self)


func _switch_to_ability_slot(slot: int):
	if slot > abilities.size(): return
	
	selected_ability_slot = slot


func _enter_tree():
	var peer_id = name.to_int()
	if peer_id in multiplayer.get_peers():
		set_multiplayer_authority(peer_id, true)
	$RichTextLabel.text = "[center]" + name
	
	im = DeviceInputMap.new(peer_id, [0, 2])


func set_device(device_ids: Array):
	if im != null:
		im.cleanup()
		
	var peer_id = name.to_int()
	im = DeviceInputMap.new(peer_id, device_ids)


func _physics_process(delta):
	if not is_multiplayer_authority():
		return
	
	if controller != null:
		controller.handle_pre_physics(delta)
		controller.handle_physics(delta)
		controller.handle_post_physics(delta)


func get_center_global_position() -> Vector2:
	print(global_position, " dwdwadwadw ", center_point.global_position)
	return center_point.global_position
