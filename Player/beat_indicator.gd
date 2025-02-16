extends Node2D

@export var anim : AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Conductor.quarter_beat.connect(restart_anim)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# restarts the animation and sets its speed based on the bpm
func restart_anim(i : int):
	anim.stop()
	anim.play()
	anim.speed_scale = 1 / Conductor.seconds_per_quarter_note
	
