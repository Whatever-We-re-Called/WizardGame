class_name Player extends CharacterBody2D

signal killed(int)
signal paused
signal received_debug_input(int)

@export var controller: PlayerController

@onready var sprite_2d: Sprite2D = %Sprite2D
@onready var center_point = %CenterPoint
@onready var change_abilities_ui: CenterContainer = $CanvasLayer/ChangeAbilitiesUI
@onready var player_collision_shape_2d: CollisionShape2D = %PlayerCollisionShape2D
@onready var spell_inventory: SpellInventory = %SpellInventory
@onready var spell_nodes: Node = %SpellNodes


var peer_id: int
var im: DeviceInputMap
var can_use_abilities: bool = true
var is_dead = false


func _enter_tree():
	peer_id = name.to_int()
	
	im = DeviceInputMap.new(self, peer_id, [0, 2])
	if not SessionManager.is_playing_local():
		if peer_id in multiplayer.get_peers() or SessionManager.get_self_peer_id() == peer_id:
			set_multiplayer_authority(peer_id, true)


func _ready():
	if is_multiplayer_authority():
		var spells = {
			Spells.Type.WIND_GUST: 1,
			Spells.Type.REMOTE_LAND_MINE: 1,
			Spells.Type.PLATFORM: 1
		}
		spell_inventory.init_starting_spells(spells)
		
		change_abilities_ui.setup(self)

	if SessionManager.connection_strategy is SteamBasedStrategy and is_multiplayer_authority():
		var steam_info = SteamWrapper.get_friend_info(SessionManager.connected_clients[peer_id].steam_id)
		$RichTextLabel.text = "[center]" + steam_info.display_name
	else:
		$RichTextLabel.text = "[center]Player " + name


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


func add_velocity(addi_velocity: Vector2):
	if SessionManager.is_valid_peer(self):
		_add_velocity_rpc.rpc_id(get_peer_id(), addi_velocity)
	else:
		_add_velocity_rpc(addi_velocity)


@rpc("any_peer", "call_local")
func _add_velocity_rpc(addi_velocity: Vector2):
	apply_central_impulse(addi_velocity)
