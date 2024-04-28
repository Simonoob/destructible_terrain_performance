extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	$explosion.play('explode')


func _on_explosion_animation_finished():
	queue_free()
