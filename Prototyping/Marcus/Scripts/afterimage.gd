extends Node2D

func _ready() -> void:
	$Timer.timeout.connect(_on_timer_timeout)

func _on_timer_timeout():
	# Removes this node from the scene tree
	queue_free()
