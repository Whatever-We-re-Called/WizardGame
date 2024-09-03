extends Node

var active_shards: Dictionary
var shard_sync_data: Array


func _physics_process(delta: float):
	if multiplayer.is_server():
		_handle_shard_position_sync()


func _handle_shard_position_sync():
	var compressed_data = MultiplayerUtil.get_compressed_data(shard_sync_data)
	_handle_shard_position_sync_rpc.rpc(compressed_data)
	shard_sync_data.clear()


@rpc("authority", "call_local", "unreliable")
func _handle_shard_position_sync_rpc(compressed_data: PackedByteArray):
	var data = MultiplayerUtil.get_decompressed_data(compressed_data)
	for entry in data:
		var shard = get_tree().root.get_node(active_shards[entry[0]])
		if shard != null:
			shard.replicated_position = entry[1]
			shard.replicated_rotation = entry[2]
			shard.replicated_linear_velocity = entry[3]
			shard.replicated_angular_velocity = entry[4]


func append_shard_sync_data(shard: BreakableBody2D):
	shard_sync_data.append([
		shard.id,
		shard.position,
		shard.rotation,
		shard.linear_velocity,
		shard.angular_velocity
	])


func append_active_shard(shard: BreakableBody2D):
	append_active_shard_rpc.rpc(shard.id, shard.get_path())


@rpc("authority", "call_local", "reliable")
func append_active_shard_rpc(id: int, shard_path: String):
	active_shards[id] = shard_path


func get_new_shard_id() -> int:
	var chosen_id = 0
	var rng = RandomNumberGenerator.new()
	while chosen_id == 0 and active_shards.has(chosen_id):
		chosen_id = rng.randi_range(1, 65535)
	
	return chosen_id
