extends Node2D

@export var anim : AnimationPlayer

# restarts the animation and sets its speed based on the bpm
func restart_anim(i : int):
	anim.stop()
	anim.play()
	anim.speed_scale = 1 / Conductor.seconds_per_quarter_note
	
