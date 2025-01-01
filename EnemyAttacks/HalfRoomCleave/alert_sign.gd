extends AnimatedSprite2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Conductor.quarter_beat.connect(_on_quarter_beat)

func _on_quarter_beat(_beat_num: int):
	visible = !visible
