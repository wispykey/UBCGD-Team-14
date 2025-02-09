extends Node2D

@onready var player := $Player
@onready var hud := $HUD

@export var half_room_cleave: PackedScene
@export var spawn_ghost: PackedScene
@export var puddle_hazard: PackedScene
@export var thunderstorm: PackedScene
@export var iterative_projectile: PackedScene

@export var debug_random_test: bool = false
var GameOverComponent = preload("res://Components/GameOver.tscn")
var VictoryComponent = preload("res://Components/Victory.tscn")

var window_dimensions: Vector2
const WIDTH: int = 640
const HEIGHT: int = 448
const TILE_SIZE: int = 32
const HOR_TILES: int = WIDTH / TILE_SIZE
const VER_TILES: int = HEIGHT / TILE_SIZE
const WINNING_SCORE: int = 20

#const TILES = {
	#"RED": {"src": 2, "atlas": Vector2(0,0), "alt": 3},
	#"DANGER": {"src": 3, "atlas": eVector2(0, 0), "alt": 0},
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
	{"time": 4, "function": "spawn_thunderstorm", "args": {}},
	#{"time": 4, "function": "cleave", "args": {}}, # Test defaulting to West
	{"time": 18, "function": "spawn_vines_in_cross_pattern", "args": {}},
	{"time": 18, "function": "spawn_vines_in_cross_pattern", "args": {"coords": Vector2(4,4)}},
	{"time": 18, "function": "spawn_vines_in_cross_pattern", "args": {"coords": Vector2(10,4)}},
	{"time": 18, "function": "spawn_vines_in_cross_pattern", "args": {"coords": Vector2(16,4)}},
	{"time": 18, "function": "spawn_vines_in_cross_pattern", "args": {"coords": Vector2(4,7)}},
	{"time": 18, "function": "spawn_vines_in_cross_pattern", "args": {"coords": Vector2(16,7)}},
	{"time": 18, "function": "spawn_vines_in_cross_pattern", "args": {"coords": Vector2(4,10)}},
	{"time": 18, "function": "spawn_vines_in_cross_pattern", "args": {"coords": Vector2(10,10)}},
	{"time": 18, "function": "spawn_vines_in_cross_pattern", "args": {"coords": Vector2(16,10)}},
	{"time": 22, "function": "spawn_puddles_periodically", "args": {}},
	#{"time": 20, "function": "spawn_ghost_on_player", "args": {}},
	#{"time": 24, "function": "spawn_ghost_on_player", "args": {}},
	#{"time": 25, "function": "spawn_ghost_on_player", "args": {}},
	#{"time": 30, "function": "spawn_ghost_on_player", "args": {}},
]
var next_event: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Declare a function to be executed whenever the quarter_beat signal is emitted
	Conductor.quarter_beat.connect(_on_quarter_beat)
	Conductor.song_finished.connect(_on_song_finished)
	GameEvents.player_died.connect(_on_player_died)
	window_dimensions =  get_viewport_rect().size
	
	%Player.position = get_viewport_rect().get_center()
	Conductor.set_music("Fantasy2")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	print(HOR_TILES, " ", VER_TILES)
	pass

# Function to be called whenever quarter_beat signal is emitted
func _on_quarter_beat(beat_num: int):
	GameState.score += 1
	GameEvents.score_changed.emit()
	
	# Guard against indexing out-of-bounds
	if next_event >= len(timeline):
		return
	
	# Check if the next event in timeline queue should start
	while int(floor(Conductor.num_beats_passed)) == timeline[next_event].time:
		call(timeline[next_event].function, timeline[next_event].args)
		next_event += 1
		if next_event >= len(timeline):
			break

func _on_song_finished():
	# Only check score once song has finished (i.e. player must survive entire song)
	if GameState.score >= WINNING_SCORE:
		var victory = VictoryComponent.instantiate()
		add_child(victory)

func _on_player_died():
	# TODO: Despawn player, stop processing input
	timeline = []
	var game_over = GameOverComponent.instantiate()
	add_child(game_over)
	Conductor.stop_music()

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
	
	
func spawn_thunderstorm(args: Dictionary):
	var storm = thunderstorm.instantiate()
	storm.set_waves(4)
	storm.set_strikes(8)
	add_child(storm)

func spawn_ghost_on_player(args: Dictionary):
	var ghost = spawn_ghost.instantiate()
	ghost.position = %Player.position
	add_child(ghost)
	
func spawn_puddles_periodically(args: Dictionary):
	Conductor.quarter_beat.connect(_on_quarter_beat_spawn_puddle)
	

func spawn_vines_in_cross_pattern(args: Dictionary):
	var coords = args.coords if args.has("coords") else Vector2(10, 7)
	var calls = [
		{"direction": "NORTH", "coord_x": coords.x, "coord_y": coords.y},
		{"direction": "EAST", "coord_x": coords.x, "coord_y": coords.y},
		{"direction": "WEST", "coord_x": coords.x, "coord_y": coords.y},
		{"direction": "SOUTH", "coord_x":coords.x, "coord_y": coords.y}
	]
	for spawn_vines_args in calls:
		call("spawn_vines", spawn_vines_args)
	

func spawn_vines(args: Dictionary):
	var projectile = iterative_projectile.instantiate()
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


func _on_quarter_beat_spawn_puddle(beat_num: int):
	# Only every four beats, starting on beat two of a measure
	if floori(Conductor.num_beats_passed) % 4 != 2:
		return
		
	#print("Spawning puddle")
	var puddle = puddle_hazard.instantiate()
	puddle.position = %Player.position
	add_child(puddle)
	if debug_random_test:
		var random_width = randi_range(3,6)
		# Always square, just for testing
		puddle.set_dimensions(Vector2(random_width, random_width-1))
		puddle.position = get_viewport_rect().get_center()
		puddle.position += randi_range(-5,5) * Vector2(TILE_SIZE, TILE_SIZE)
	puddle.start()
