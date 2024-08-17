@tool
extends Area2D

@export var zone_size: Vector2:
	get:
		return _zone_size
	set(value):
		_zone_size = value
		_update_zone_size()

var _zone_size: Vector2


func _ready():
	_update_zone_size()


func _update_zone_size():
	$CollisionShape2D.shape = RectangleShape2D.new()
	$CollisionShape2D.shape.size = _zone_size
	$CollisionShape2D.position = Vector2.ZERO


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		print(body)
		body.kill()
