extends AnimatedSprite2D

var duration: float
var time_left: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Conductor.quarter_beat.connect(_on_quarter_beat_fade)
	material = material.duplicate()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time_left -= delta
	if time_left < 0:
		call_deferred("queue_free")
	
# Must be called before added to tree and processing begins
func set_duration(beats: int):
	duration = beats * Conductor.seconds_per_quarter_note
	time_left = duration
	
	
func _on_quarter_beat_fade(beat_num: int):
	var progress = 1 - time_left / duration
	progress = clamp(progress, 0.0, 1.0)
	var new_alpha = lerp(1.0, 0.4, progress)
	material.set("shader_parameter/current_alpha", new_alpha)
	
