extends Node2D

@onready var player := $Player

const TILE_WIDTH: int = 32
const TILE_HEIGHT: int = 32

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
	if beat_num == 4 :
		spawn_multiple_projectile_from_bottom(4)
	else:
		spawn_projectile_at_random_top_location()
	

	
	
	# Uncomment the call below to simulate the grid-based movement we will have
	# move_one_tile_right()

# Moves right by the width of one tile
func move_one_tile_right():
	player.position.x += TILE_WIDTH

func spawn_multiple_projectile_from_bottom(num_projectiles: int):
	var SPACING = TILE_WIDTH *2
	var window_dimensions: Vector2 = get_viewport_rect().size
	var starting_x = randi_range(SPACING, window_dimensions.x - TILE_WIDTH * 4)
	for n in num_projectiles:
		var projectile = load("res://Prototyping/Amelie1/projectile.tscn")
		var projectile_instance = projectile.instantiate()
		projectile_instance.SPEED = -projectile_instance.SPEED
		projectile_instance.position = Vector2(starting_x, window_dimensions.y + TILE_WIDTH)
		starting_x = starting_x + SPACING
		add_child(projectile_instance)

# You can add scenes dynamically via GDScript code
func spawn_projectile_at_random_top_location():
	# First, load the asset
	var projectile = load("res://Prototyping/Amelie1/projectile.tscn")
	# Then, instantiate it
	var projectile_instance = projectile.instantiate()
	# Set whatever parameters you need to
	projectile_instance.position = get_random_position()
	# You must add it to the scene tree as well (in this case, a child of ExampleLevel)
	add_child(projectile_instance)


func get_random_position() -> Vector2:
	# Get the window size
	var window_dimensions: Vector2 = get_viewport_rect().size
	# Keep position well-within bounds
	var random_x = randi_range(TILE_WIDTH * 2, window_dimensions.x - TILE_WIDTH * 2)
	var y = TILE_HEIGHT
	
	return Vector2(random_x, y)
