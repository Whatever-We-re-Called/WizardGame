extends Node
class_name CustomSynchronizer

var player:
	get():
		return get_parent()
var fields_to_sync = []
var old_values = {}
	

func _process(delta: float) -> void:
	if fields_to_sync.is_empty(): return
	
	if is_multiplayer_authority():
		for peer_id in SessionManager.sync_filter:
			if peer_id != SessionManager.get_self_peer_id():
				_handle_sync(peer_id)
				
		for field in fields_to_sync:
			old_values[field.label] = field.getter.call()
	
	
@rpc("any_peer", "reliable")
func _handle_sync(peer_id, force = false):
	for field in fields_to_sync:
		var label = field.label
		var value = field.getter.call()
		if changed(label, value) or force:
			update.rpc_id(peer_id, label, value)
	
	
func changed(field, value):
	return not old_values.has(field) or old_values[field] != value
	
	
@rpc
func update(label, value):
	for field in fields_to_sync:
		if field.label == label:
			field.setter.call(value)
	
	
class FieldSync:
	var label: String
	var getter: Callable
	var setter: Callable
	
	func _init(label, getter, setter):
		self.label = label
		self.getter = getter
		self.setter = setter
		
