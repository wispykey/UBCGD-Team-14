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

# A queue of scheduled function calls.
# 	'time' is measured in beats; must be strictly non-decreasing
#   'function' is the name of a function in this script; must be in quotation marks
# 	'args' is a dictionary of additional parameters to 'function'
var timeline = [
	{"time": 12, "function": "spawn_projectile_at_position", "args": {"coord_x": 5, "coord_y": 6}},
	{"time": 16, "function": "spawn_projectile_at_position", "args": {"direction": "NORTH", "coord_x": 3, "coord_y": 5}},
	{"time": 20, "function": "spawn_projectile_at_position", "args": {"direction": "SOUTH", "coord1_x": 15, "coord1_y": 5, "coord2_x": 16, "coord2_y": 5, "coord3_x": 17, "coord3_y": 5}},
	{"time": 24, "function": "spawn_projectile_at_position", "args": {"direction": "WEST", "coord1_x": 7, "coord1_y": 5, "coord2_x": 9, "coord2_y": 9}},
	{"time": 40, "function": "spawn_projectile_at_position", "args": {"direction": "WEST", "type": "EXPANDING", "coord_x": 5, "coord_y": 5}},
	{"time": 60, "function": "spawn_projectile_at_position", "args": {"direction": "WEST", "type": "SPINNING", "turn": "4", "coord_x": 5, "coord_y": 5}},
	{"time": 64, "function": "spawn_projectile_at_position", "args": {"direction": "NORTH", "type": "SPINNING", "turn": "3", "coord_x": 5, "coord_y": 7}},
	{"time": 68, "function": "spawn_projectile_at_position", "args": {"direction": "SOUTH", "type": "SPINNING", "turn": "7", "coord_x": 15, "coord_y": 3}},
	{"time": 72, "function": "spawn_projectile_at_position", "args": {"direction": "WEST", "type": "SPINNING", "coord_x": 7, "coord_y": 4}},
	{"time": 78, "function": "spawn_projectile_at_position", "args": {"direction": "WEST", "type": "TRACKING", "coord_x": 10, "coord_y": 10}},
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
	

# Can spawn up to 5 projectiles at athe same time currently
func spawn_projectile_at_position(args: Dictionary):
	var projectile = spawn_projectile.instantiate()
	var type  = args.type if args.has("type") else ""
	var direction  = args.direction if args.has("direction") else ""
	var turn_count = int(args.turn) if args.has("turn") else 0
	var coords
	if (args.has("coord1_x") && args.has("coord1_y")):
		coords = PackedVector2Array()
		coords.append(Vector2(int(args.coord1_x), int(args.coord1_y)))
		if (args.has("coord2_x") && args.has("coord2_y")):
			coords.append(Vector2(int(args.coord2_x), int(args.coord2_y)))
			if (args.has("coord3_x") && args.has("coord3_y")):
				coords.append(Vector2(int(args.coord3_x), int(args.coord3_y)))
				if (args.has("coord4_x") && args.has("coord4_y")):
					coords.append(Vector2(int(args.coord4_x), int(args.coord4_y)))
					if (args.has("coord5_x") && args.has("coord5_y")):
						coords.append(Vector2(int(args.coord5_x), int(args.coord5_y)))
		add_child(projectile)
		projectile.start(direction, type, coords, turn_count)
		return
	elif (args.has("coord_x") && args.has("coord_y")):
		coords = Vector2(int(args.coord_x), int(args.coord_y))
	else:
		coords = Vector2(0, 0)
	add_child(projectile)
	projectile.start_one_coord(direction, type, coords, turn_count)
	

func spawn_projectile_at_random(args: Dictionary):
	var projectile = spawn_projectile.instantiate()
	var type  = args.type if args.has("type") else ""
	var direction  = args.direction if args.has("direction") else ""
	var coords = get_random_position()
	var turn_count = int(args.turn) if args.has("turn") else 2
	add_child(projectile)
	projectile.start_one_coord(direction, type, coords, turn_count)
