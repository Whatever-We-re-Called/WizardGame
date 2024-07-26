class_name Player extends CharacterBody2D

@export var abilities: Array[Ability]
@export var controller: PlayerController

@onready var center_point = %CenterPoint

var im: DeviceInputMap


func _enter_tree():
	var peer_id = name.to_int()
	if peer_id in multiplayer.get_peers() or SessionManager.get_self_peer_id() == peer_id:
		set_multiplayer_authority(peer_id, true)
	$RichTextLabel.text = "[center]" + name
	
	im = DeviceInputMap.new(self, peer_id, [0, 2])


func set_device(device_ids: Array):
	if im != null:
		im.cleanup()
		
	var peer_id = name.to_int()
	im = DeviceInputMap.new(self, peer_id, device_ids)


func _physics_process(delta):
	if not is_multiplayer_authority():
		return
	
	if controller != null:
		controller.handle_pre_physics(delta)
		controller.handle_physics(delta)
		controller.handle_post_physics(delta)


func get_center_global_position() -> Vector2:
	return center_point.global_position


func get_pointer_direction() -> Vector2:
	# TODO Add support for different logic for different devices.
	return get_center_global_position().direction_to(get_global_mouse_position()).normalized()
	
