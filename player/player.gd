class_name Player extends CharacterBody2D

signal killed(int)
signal received_debug_input(int)

@export var ability_1: Abilities.Type
@export var ability_2: Abilities.Type
@export var ability_3: Abilities.Type
@export var controller: PlayerController

@onready var sprite_2d: Sprite2D = %Sprite2D
@onready var ability_nodes = %AbilityNodes
@onready var center_point = %CenterPoint
@onready var ability_multiplayer_spawner: MultiplayerSpawner = %AbilityMultiplayerSpawner
@onready var change_abilities_ui: CenterContainer = $CanvasLayer/ChangeAbilitiesUI
@onready var abilities: Array[Abilities.Type] = [ ability_1, ability_2, ability_3 ]
@onready var player_collision_shape_2d: CollisionShape2D = %PlayerCollisionShape2D

var peer_id: int
var im: DeviceInputMap
var can_use_abilities: bool = true
var is_dead = false


func _enter_tree():
	peer_id = name.to_int()
	
	im = DeviceInputMap.new(self, peer_id, [0, 2])
	if peer_id in multiplayer.get_peers() or SessionManager.get_self_peer_id() == peer_id:
		set_multiplayer_authority(peer_id, true)
	$RichTextLabel.text = "[center]" + name


func _ready():
	change_abilities_ui.visible = false
	change_abilities_ui.setup(self)
	
	for ability_scene in Abilities.loaded_ability_scenes.values():
		ability_multiplayer_spawner.add_spawnable_scene(ability_scene.resource_path)


func set_device(device_ids: Array):
	if im != null:
		im.cleanup()
		
	peer_id = name.to_int()
	im = DeviceInputMap.new(self, peer_id, device_ids)


func _physics_process(delta):
	if not is_multiplayer_authority():
		return
	
	if controller != null:
		controller.handle_debug_inputs()
		if not is_dead:
			controller.handle_pre_physics(delta)
			controller.handle_physics(delta)
			controller.handle_post_physics(delta)


func create_ability_nodes():
	if SessionManager.is_valid_peer(self):
		_create_ability_nodes_rpc.rpc_id(peer_id)
	else:
		_create_ability_nodes_rpc()


@rpc("any_peer", "call_local", "reliable")
func _create_ability_nodes_rpc():
	for i in range(3):
		var ability = abilities[i]
		var ability_scene = Abilities.get_ability_scene(ability)
		var new_ability_scene = ability_scene.instantiate()
		
		if ability != Abilities.Type.NONE:
			var ability_resource = Abilities.get_ability_resource(ability)
			new_ability_scene.setup(ability_resource)
			ability_nodes.add_child(new_ability_scene, true)


@rpc("any_peer", "call_local", "reliable")
func clear_ability_nodes():
	for child in ability_nodes.get_children():
		child.queue_free()


func get_center_global_position() -> Vector2:
	return center_point.global_position


func get_direction() -> Vector2:
	return controller.previous_input_direction


func get_peer_id() -> int:
	return int("" + name)


func apply_central_impulse(force: Vector2):
	velocity += force


func kill():
	if SessionManager.is_valid_peer(self):
		_kill_rpc.rpc_id(peer_id)
	else:
		_kill_rpc()


@rpc("any_peer", "call_local", "reliable")
func _kill_rpc():
	if not is_multiplayer_authority(): return
	if is_dead: return
	
	visible = false
	can_use_abilities = false
	is_dead = true
	velocity = Vector2.ZERO
	player_collision_shape_2d.set_deferred("disabled", true)
	killed.emit(peer_id)


func revive():
	if SessionManager.is_valid_peer(self):
		_revive_rpc.rpc_id(peer_id)
	else:
		_revive_rpc()


@rpc("any_peer", "call_local", "reliable")
func _revive_rpc():
	if not is_multiplayer_authority(): return
	if not is_dead: return
	
	visible = true
	can_use_abilities = true
	is_dead = false
	player_collision_shape_2d.set_deferred("disabled", false)


func teleport(target_global_position: Vector2):
	if SessionManager.is_valid_peer(self):
		_teleport_rpc.rpc_id(get_peer_id(), target_global_position)
	else:
		_teleport_rpc(target_global_position)


@rpc("any_peer", "call_local")
func _teleport_rpc(target_global_position: Vector2):
	global_position = target_global_position


func add_velocity(velocity: Vector2):
	if SessionManager.is_valid_peer(self):
		_add_velocity_rpc.rpc_id(get_peer_id(), velocity)
	else:
		_add_velocity_rpc(velocity)


@rpc("any_peer", "call_local")
func _add_velocity_rpc(velocity: Vector2):
	apply_central_impulse(velocity)


func toggle_change_abilities_ui():
	if change_abilities_ui.visible == false:
		change_abilities_ui.visible = true
		controller.freeze_input = true
	else:
		change_abilities_ui.visible = false
		controller.freeze_input = false
