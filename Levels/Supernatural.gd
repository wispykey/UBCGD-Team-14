extends Node2D

@onready var player := $Player
@onready var hud := $HUD

@export var half_room_cleave: PackedScene
@export var spawn_ghost: PackedScene
@export var debug_random_test: bool = false

var window_dimensions: Vector2
const WIDTH: int = 640
const HEIGHT: int = 448
const TILE_SIZE: int = 32
const HOR_TILES: int = WIDTH / TILE_SIZE
const VER_TILES: int = HEIGHT / TILE_SIZE
const WINNING_SCORE: int = 100 # The score the user has to reach to win the level.

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
	{"time": 4, "function": "cleave", "args": {}}, # Test defaulting to West
	{"time": 8, "function": "cleave", "args": {"direction": "EAST"}},
	{"time": 12, "function": "cleave", "args": {"direction": "NORTH"}},
	{"time": 16, "function": "cleave", "args": {"direction": "SOUTH"}},
	{"time": 20, "function": "spawn_ghost_on_player", "args": {}},
	{"time": 24, "function": "spawn_ghost_on_player", "args": {}},
	{"time": 25, "function": "spawn_ghost_on_player", "args": {}},
	{"time": 30, "function": "spawn_ghost_on_player", "args": {}},
]
var next_event: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Declare a function to be executed whenever the quarter_beat signal is emitted
	Conductor.quarter_beat.connect(_on_quarter_beat)
	window_dimensions =  get_viewport_rect().size
	
	%Player.position = get_viewport_rect().get_center()
	Conductor.set_music("Supernatural1")

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
	# Create a random x and y for the danger sign
	# randi_range gets random integer within the range of tiles within the walls
	# x and y are scaled up, and add adjustment to align danger sign 
	# b/c danger sign position x,y is at its center, not its top left corner
	var random_x = randi_range(1, HOR_TILES - 2) * TILE_SIZE + TILE_SIZE/2
	var random_y = randi_range(1, VER_TILES - 2) * TILE_SIZE + TILE_SIZE/2
	
	return Vector2(random_x, random_y)

# Attack functions are wrappers for instantiating standalone nodes
func cleave(args: Dictionary):
	var cleave = half_room_cleave.instantiate()
	var direction = args.direction if args.has("direction") else ""
	add_child(cleave)
	if debug_random_test:
		cleave.position = get_viewport_rect().get_center()
		cleave.position += randi_range(-5,5) * Vector2(TILE_SIZE, TILE_SIZE)
	# start() depends on being added to tree beforehand
	cleave.start(direction)
	

func spawn_ghost_on_player(args: Dictionary):
	var ghost = spawn_ghost.instantiate()
	ghost.position = %Player.position
	add_child(ghost)
