extends Node

# The order of this no longer really matters.
# We no longer store this on the resource, so adding one is still dynamically registered.
enum Type {
	NONE,
	WIND_GUST,
	WAYBACK_POINT,
	REMOTE_LAND_MINE,
	DASH,
	PLATFORM
}

const resource_path = "res://spells/resources/"
var registry = {}


func _ready():
	_register_all()
	
	
func _register_all():
	registry.clear()
	
	for type in Type.keys():
		#if type == Type.keys()[Type.NONE]:
			#continue
		
		type = type.to_lower()
		
		if not FileAccess.file_exists("{0}{1}/{1}.gd".format([resource_path, type])):
			push_error("Could not find spell script for {0}. Expected to find {1}{0}/{0}.gd".format([type, resource_path]))
		if not FileAccess.file_exists("{0}{1}/{1}.tres".format([resource_path, type])):
			push_error("Could not find spell resource for {0}. Expected to find {1}{0}/{0}.tres".format([type, resource_path]))
			
		var script = load("{0}{1}/{1}.gd".format([resource_path, type]))
		var resource = ResourceLoader.load("{0}{1}/{1}.tres".format([resource_path, type]))
		
		registry[Type[type.to_upper()]] = { "script": script, "resource": resource }
		
		
func get_spell_resource(type: Spells.Type) -> Spell:
	return registry[int(type)].resource
	
	
func get_spell_script(type: Spells.Type) -> Script:
	return registry[int(type)].script


func create_node_for_rpc(type: Spells.Type, player: Player, slot: int) -> Node:
	var node = get_spell_script(type).new()
	var resource = get_spell_resource(type)
	node.name = resource.name.replace(" ", "")
	node.setup(resource, type, player, slot)
	return node
