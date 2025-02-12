extends Label

@onready var tween = get_tree().create_tween()

func _ready():
	start_blinking()

func start_blinking():
	tween.set_loops()  # Makes it loop infinitely
	tween.tween_property(self, "modulate:a", 1.0, 0.8)  # Fade out (0.5s)
	tween.tween_property(self, "modulate:a", 0.0, 0.2)  # Fade in (0.5s)
