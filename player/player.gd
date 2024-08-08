class_name Player extends CharacterBody2D

signal received_debug_input(int)

@export var ability_1: Abilities.Type
@export var ability_2: Abilities.Type
@export var ability_3: Abilities.Type
@export var controller: PlayerController

@onready var sprite_2d: Sprite2D = %Sprite2D
@onready var ability_nodes = %AbilityNodes
@onready var center_point = %CenterPoint
@onready var ability_multiplayer_spawner: MultiplayerSpawner = %AbilityMultiplayerSpawner

var im: DeviceInputMap


func _enter_tree():
	var peer_id = name.to_int()
	if peer_id in multiplayer.get_peers() or SessionManager.get_self_peer_id() == peer_id:
		set_multiplayer_authority(peer_id, true)
	$RichTextLabel.text = "[center]" + name
	
	im = DeviceInputMap.new(self, peer_id, [0, 2])


func _ready():
	update_ability_nodes.rpc()


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


@rpc("any_peer", "call_local")
func update_ability_nodes():
	var abilities = [ ability_1, ability_2, ability_3 ]
	
	for i in range(3):
		var ability = abilities[i]
		
		if ability == Abilities.Type.NONE:
			ability_nodes.get_child(i).set_script(null)
		else:
			ability_nodes.get_child(i).set_script(Abilities.get_ability(ability).execution_script)
			ability_nodes.get_child(i).setup(Abilities.get_ability(ability))


func get_center_global_position() -> Vector2:
	return center_point.global_position


func get_pointer_direction() -> Vector2:
	match im.get_device_type():
		DeviceInputMap.DeviceType.KEYBOARD_MOUSE:
			return get_center_global_position().direction_to(get_global_mouse_position()).normalized()
		DeviceInputMap.DeviceType.CONTROLLER:
			var direction = Input.get_vector(im.move_left, im.move_right, im.move_up, im.move_down)
			return direction
		_:
			return Vector2.ZERO

func get_peer_id() -> int:
	return int("" + name)


func apply_central_impulse(force: Vector2):
	velocity += force
