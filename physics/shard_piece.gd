class_name ShardPiece extends BreakableBody2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _on_creation():
	_disappear()


func _disappear():
	animation_player.play("disappear")
	await animation_player.animation_finished
	
	queue_free()
