extends Node2D

var wait_time
var afterimage_fct = 0.5 # Control opacity of afterimage

func _ready() -> void:
	wait_time = 1 / Conductor.seconds_per_quarter_note
	$Timer.wait_time = wait_time
	$Timer.timeout.connect(_on_timer_timeout)

func _process(delta: float) -> void:
	# Get time left and scale it to range [0, initial_a]
	var new_a = $Timer.time_left * afterimage_fct
	modulate.a = new_a

func _on_timer_timeout():
	# Removes this node from the scene tree
	queue_free()
