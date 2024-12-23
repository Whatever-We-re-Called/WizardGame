extends CustomSynchronizer

func _ready():
	fields_to_sync = [
		FieldSync.new("position", func get(): return player.position, func set(value): player.position = value),
		FieldSync.new("visible", func get(): return player.visible, func set(value): player.visible = value),
		FieldSync.new("collision", func get(): return %PlayerCollisionShape2D.disabled, func set(value): %PlayerCollisionShape2D.disabled = value)
	]
