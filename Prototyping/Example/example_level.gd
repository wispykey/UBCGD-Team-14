extends Node2D

@onready var player := $Player

const TILE_WIDTH: int = 32

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Declare a function to be executed whenever the quarter_beat signal is emitted
	Conductor.quarter_beat.connect(_on_quarter_beat)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	

# Function to be called whenever quarter_beat signal is emitted
func _on_quarter_beat(beat_num: int):
	# Do something on each beat here!
	spawn_danger_sign_at_random_location()
	
	# Uncomment the call below to simulate the grid-based movement we will have
	# move_one_tile_right()

# Moves right by the width of one tile
func move_one_tile_right():
	player.position.x += TILE_WIDTH


# You can add scenes dynamically via GDScript code
func spawn_danger_sign_at_random_location():
	# First, load the asset
	var danger_sign = load("res://Prototyping/Example/DangerSign.tscn")
	# Then, instantiate it
	var danger_sign_instance = danger_sign.instantiate()
	var danger_sign_instance2 = danger_sign.instantiate()
	# Set whatever parameters you need to
	var position1 = get_random_position()
	var position2 = get_random_position()
	
	while position1 == position2:
		position2 = get_random_position()
		
	danger_sign_instance.position = position1
	danger_sign_instance2.position = position2
	# You must add it to the scene tree as well (in this case, a child of ExampleLevel)
	add_child(danger_sign_instance)
	add_child(danger_sign_instance2)


func get_random_position() -> Vector2:
	# Get the window size
	var window_dimensions: Vector2 = get_viewport_rect().size
	# Keep position well-within bounds
	var random_x = randi_range(TILE_WIDTH * 2, window_dimensions.x - TILE_WIDTH * 2)
	var random_y = randi_range(TILE_WIDTH * 2, window_dimensions.y - TILE_WIDTH * 2)
	
	return Vector2(random_x, random_y)
