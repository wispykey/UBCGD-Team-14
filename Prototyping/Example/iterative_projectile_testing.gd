extends Node2D

@onready var player := $Player
@onready var hud := $HUD

@export var spawn_projectile: PackedScene
@export var debug_random_test: bool = false

var window_dimensions: Vector2
const WIDTH: int = 640
const HEIGHT: int = 448
const TILE_SIZE: int = 32
const HOR_TILES: int = WIDTH / TILE_SIZE
const VER_TILES: int = HEIGHT / TILE_SIZE

#const TILES = {
	#"RED": {"src": 2, "atlas": Vector2(0,0), "alt": 3},
	#"DANGER": {"src": 3, "atlas": Vector2(0, 0), "alt": 0},
	#"FLOOR_DARK": {"src": 1, "atlas": Vector2(0,0), "alt": 3},
	#"FLOOR_MED": {"src": 1, "atlas": Vector2(0,0), "alt": 1},
	#"FLOOR_LIGHT": {"src": 1, "atlas": Vector2(0,0), "alt": 0},
	#"GHOST": {"src": 0, "atlas": Vector2(0, 0), "alt": 0},
#}
#const DEFAULT_FLOOR = TILES.FLOOR_DARK

# A queue of scheduled function calls.
# 	'time' is measured in beats; must be strictly non-decreasing
#   'function' is the name of a function in this script; must be in quotation marks
# 	'args' is a dictionary of additional parameters to 'function'
var timeline = [
	{"time": 4, "function": "spawn_projectile_at_random", "args": {}},
	{"time": 8, "function": "spawn_projectile_at_random", "args": {"direction": "NORTH"}},
	{"time": 12, "function": "spawn_projectile_at_random", "args": {"direction": "SOUTH"}},
	{"time": 16, "function": "spawn_projectile_at_random", "args": {"direction": "WEST"}},
]
var next_event: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Declare a function to be executed whenever the quarter_beat signal is emitted
	Conductor.quarter_beat.connect(_on_quarter_beat)
	window_dimensions =  get_viewport_rect().size
	
	%Player.position = get_viewport_rect().get_center()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	

# Function to be called whenever quarter_beat signal is emitted
func _on_quarter_beat(beat_num: int):
	GameState.score += 1
	GameEvents.score_changed.emit()
	
	# Guard against indexing out-of-bounds
	if next_event >= len(timeline):
		return
	
	# Check if the next event in timeline queue should start
	if int(floor(Conductor.num_beats_passed)) == timeline[next_event].time:
		call(timeline[next_event].function, timeline[next_event].args)
		next_event += 1


func _on_eighth_beat(_beat_num: int):
	pass


func get_random_position() -> Vector2:
	# Create a random x and y for the telegraph and place a projectile there when the telegraph timer runs out
	# Measured in tiles
	var random_x = randi_range(1, HOR_TILES - 2)
	var random_y = randi_range(1, VER_TILES - 2)
	
	return Vector2(random_x, random_y)
	

func spawn_projectile_at_position(args: Dictionary):
	var projectile = spawn_projectile.instantiate()
	var type  = args.type if args.has("type") else ""
	var direction  = args.direction if args.has("direction") else ""
	var coords
	if (args.has("coords")):
		coords = args.coords
		projectile.start(direction, type, coords)
		return
	elif (args.has("coord")):
		coords = args.coord
	else:
		coords = Vector2(0, 0)
	add_child(projectile)
	projectile.start_one_coord(direction, type, coords)
	

func spawn_projectile_at_random(args: Dictionary):
	var projectile = spawn_projectile.instantiate()
	var type  = args.type if args.has("type") else ""
	var direction  = args.direction if args.has("direction") else ""
	var coords = get_random_position()
	add_child(projectile)
	projectile.start_one_coord(direction, type, coords)
