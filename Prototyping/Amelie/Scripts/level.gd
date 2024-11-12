extends Node


var x_width = 125
var y_width = 75

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Declare a function to be executed whenever the quarter_beat signal is emitted
	Conductor.quarter_beat.connect(_on_quarter_beat)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	

# Function to be called whenever quarter_beat signal is emitted
func _on_quarter_beat(beat_num: int):
	line_projectiles_down()
	# Do something on each beat here!
	
func line_projectiles_down():
	for n in 4:
		var projectile = load("res://Prototyping/Amelie/Scenes/projectile.tscn")
		var projectile_instance = projectile.instantiate()
		projectile_instance.position = Vector2(-x_width + x_width/3 * n, -y_width)
		add_child(projectile_instance)
