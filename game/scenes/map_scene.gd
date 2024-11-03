class_name MapScene extends PlayableScene

func _ready():
	# Uncomment below when innevtibly needed.
	#super._ready()
	DisasterManager.set_disaster_area($DisasterArea.polygon)
