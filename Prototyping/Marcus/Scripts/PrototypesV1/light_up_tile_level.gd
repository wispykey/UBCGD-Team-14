extends Node2D

@onready var player := $TilePlayer

const TILE_WIDTH: int = 32
const WIDTH: int = 640
const HEIGHT: int = 480
const HOR_TILES: int = WIDTH / TILE_WIDTH
const VER_TILES: int = HEIGHT / TILE_WIDTH

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Declare a function to be executed whenever the quarter_beat signal is emitted
	Conductor.quarter_beat.connect(_on_quarter_beat)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	

# Function to be called whenever quarter_beat signal is emitted
func _on_quarter_beat(_beat_num: int):
	# Do something on each beat here!
	spawn_danger_sign_at_random_location()
	
	# Uncomment the call below to simulate the grid-based movement we will have
	# move_one_tile_right()
	
func _on_eighth_beat(_beat_num: int):
	spawn_danger_sign_at_random_location()

# Moves right by the width of one tile
#func move_one_tile_right():
	#player.position.x += TILE_WIDTH


# You can add scenes dynamically via GDScript code
func spawn_danger_sign_at_random_location():
	# First, load the asset
	var danger_sign = load("res://Prototyping/Marcus/Scenes/DangerSign.tscn")
	# Then, instantiate it
	var danger_sign_instance = danger_sign.instantiate()

	# Set whatever parameters you need to
	danger_sign_instance.position = get_random_position()

	# You must add it to the scene tree as well (in this case, a child of ExampleLevel)
	#add_child(danger_sign_instance)


func get_random_position() -> Vector2:
	# Get the window size
	#var window_dimensions: Vector2 = get_viewport_rect().size
	
	# Create a random x and y for the danger sign
	# randi_range gets random integer within the range of tiles within the walls
	# x and y are scaled up, and add adjustment to align danger sign 
	# b/c danger sign position x,y is at its center, not its top left corner
	var random_x = randi_range(1, HOR_TILES - 2) * TILE_WIDTH + TILE_WIDTH/2
	var random_y = randi_range(1, VER_TILES - 2) * TILE_WIDTH + TILE_WIDTH/2
	
	return Vector2(random_x, random_y)
