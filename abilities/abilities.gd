extends Node

# IMPORTANT NOTE: 
# Due to how Godot stores Enums, if you were to change the integer
# value of an enum entry, or if you were to delete an enum entry
# altogether, Godot will make inappropriate assumptions on what to
# replace any references to the changed type with.
# 
# It's okay to remove entries, but DO NOT add entries within the center
# or as replacements. Always add a new entry with a newly unique integer
# value on the bottom.
enum Type {
	NONE = 0,
	WIND_GUST = 1
}

static var loaded_abilities = {}


func _ready():
	Abilities.load_all_abilities()


static func load_ability(type: Type, resource: Ability):
	loaded_abilities[type] = resource


static func get_ability(type: Type) -> Resource:
	if loaded_abilities.has(type):
		return loaded_abilities[type]
	else:
		return null


static func get_type(ability: Ability) -> Type:
	for key in loaded_abilities.keys():
		if loaded_abilities[key] == ability:
			return key
	return 0


static func load_all_abilities():
	var resource_file_paths = _get_all_ability_resource_file_paths("res://abilities/resources/")
	
	var regex = RegEx.new()
	regex.compile("[a-z,A-Z,0-9,_]*.tres")
	for resource_file_path in resource_file_paths:
		var result = regex.search(resource_file_path)
		if result != null:
			var result_string = result.get_string()
			var file_name = result_string.substr(0, result_string.length() - 5)
			var ability_type = Type.get(file_name.to_upper())
			
			# Added ".trim_suffix(".remap")" to fix a strange Godot 4.3 build 
			# export bug.
			load_ability(ability_type, load(resource_file_path.trim_suffix(".remap")))


static func _get_all_ability_resource_file_paths(path: String) -> Array[String]:  
	var file_paths: Array[String] = []  
	var dir = DirAccess.open(path)  
	dir.list_dir_begin()  
	var file_name = dir.get_next()  
	while file_name != "":  
		var file_path = path + "/" + file_name  
		if dir.current_is_dir():  
			file_paths += _get_all_ability_resource_file_paths(file_path)  
		else:  
			file_paths.append(file_path)  
		file_name = dir.get_next()
	return file_paths
