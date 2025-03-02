extends Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#start_blinking()
	pass # Replace with function body.	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func start_blinking():
	#pass
	var tween = create_tween().set_loops()
	tween.tween_property(self, "visible", false, 0.5)  # Hide after 0.5 sec
	tween.tween_property(self, "visible", true, 0.5)   # Show after 0.5 sec
