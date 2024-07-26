extends CharacterBody2D

@export var controller: PlayerController
var im: DeviceInputMap

func _enter_tree():
	var peer_id = name.to_int()
	if peer_id in multiplayer.get_peers():
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
