extends Label

func _ready():
	start_blinking()

func start_blinking():
	var tween = create_tween().set_loops()  # Makes it loop infinitely
	tween.tween_property(self, "modulate:a", 1.0, 0.8)  # Fade out (0.5s)
	tween.tween_property(self, "modulate:a", 0.0, 0.2)  # Fade in (0.5s)
	tween.tween_interval(0.15)
