extends AbilityExecution

var current_remote_land_mine_scene: Node2D

const MAX_PUSH_FORCE = 750.0
const REMOTE_LAND_MINE_SCENE = preload("res://abilities/scenes/remote_land_mine_scene.tscn")

func _on_button_up() -> bool:
	if current_remote_land_mine_scene == null:
		_place_remote_land_mine.rpc(player.get_peer_id())
		return false
	else:
		_explode_remote_land_mine_server.rpc_id(1, current_remote_land_mine_scene.global_position)
		_explode_remote_land_mine.rpc()
		return true


@rpc("any_peer", "call_local")
func _place_remote_land_mine(executor_peer_id: int):
	current_remote_land_mine_scene = REMOTE_LAND_MINE_SCENE.instantiate()
	current_remote_land_mine_scene.global_position = player.global_position
	player.ability_nodes.add_child(current_remote_land_mine_scene)
	await get_tree().process_frame
	current_remote_land_mine_scene.add_collision_exception_with(player)
	current_remote_land_mine_scene.get_node("./ButtonArea").body_entered.connect(_remote_land_mine_triggered)


@rpc("any_peer", "call_local")
func _explode_remote_land_mine_server(mine_global_position: Vector2):
	if current_remote_land_mine_scene == null: return
	var impact_polygon = PolygonUtil.get_polygon_from_radius(16, 175.0)
	impact_polygon = PolygonUtil.get_translated_polygon(impact_polygon, mine_global_position)
	
	PhysicsManager.ImpulseBuilder.new()\
		.collision_polygon(impact_polygon)\
		.affected_environment_layers([BreakableBody2D.EnvironmentLayer.ALL])\
		.applied_body_impulse(_push_body.bindv([player, mine_global_position]))\
		.applied_player_impulse(_push_player.bindv([player, mine_global_position]))\
		.execute()


@rpc("any_peer", "call_local")
func _explode_remote_land_mine():
	if current_remote_land_mine_scene == null: return
	
	var sprite = Sprite2D.new()
	sprite.texture = preload("res://abilities/textures/shitty_remote_land_mine_explosion_texture.png")
	sprite.global_position = current_remote_land_mine_scene.global_position
	add_child(sprite)
	
	current_remote_land_mine_scene.call_deferred("queue_free")
	
	await Engine.get_main_loop().create_timer(0.5).timeout
	sprite.queue_free()


func _push_body(body: PhysicsBody2D, executor_player: Player, mine_global_position: Vector2) -> Vector2:
	var direction = (body.global_position - mine_global_position).normalized()
	var push_force = _get_push_force(body, mine_global_position)
	return direction * push_force


func _push_player(player: Player, executor_player: Player, mine_global_position: Vector2) -> Vector2:
	var direction = (player.global_position - mine_global_position).normalized()
	var push_force = _get_push_force(player, mine_global_position) * 2.5
	player.velocity = Vector2.ZERO
	return direction * push_force

# TODO Revisit game feel of this (literally just inappropriately copied
# from wind_gust.gd.
func _get_push_force(body: PhysicsBody2D, mine_global_position: Vector2) -> float:
	var distance = mine_global_position.distance_to(body.global_position)
	var distance_ratio = 1.0 - (distance / 500.0)
	distance_ratio = clamp(distance_ratio, 0.0, 1.0)
	var power_ratio = EasingFunctions.ease_out_circ(0.0, 1.0, distance_ratio)
	return MAX_PUSH_FORCE * power_ratio


func _remote_land_mine_triggered(body: Node):
	if body != player and body != current_remote_land_mine_scene:
		_explode_remote_land_mine.rpc()
