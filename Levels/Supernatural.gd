extends Node2D

@onready var player := $Player
@onready var hud := $HUD

@export var half_room_cleave: PackedScene # TODO remove?
@export var spawn_ghost: PackedScene
@export var spawn_projectile: PackedScene
@export var spawn_afterimage: PackedScene
@export var dash_telegraph: PackedScene
@export var debug_random_test: bool = false

var window_dimensions: Vector2
const WIDTH: int = 640
const HEIGHT: int = 448
const TILE_SIZE: int = 32
const HOR_TILES: int = WIDTH / TILE_SIZE
const VER_TILES: int = HEIGHT / TILE_SIZE
const WINNING_SCORE: int = 100 # The score the user has to reach to win the level.

var telegraph # An instance of the dash_telegraph
var dash_telegraph_rect # A basic rectangle for the telegraph
var dash_telegraph_rect_size = TILE_SIZE * 0.8

# TODO: The following code is a tile dictionary for if we wanted to "Light up" the map
#       beyond solid blue tiles, ie. the tiles look like "cleaner" FLOOR_DARK tiles
#       by using alternate versions. Can probably be removed.
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
	# Intro
	{"time": 1, "function": "spawn_pr", "args": {"direction": "SOUTH", "coord1_x": 6, "coord1_y": 5, "coord2_x": 14, "coord2_y": 5}},
	{"time": 5, "function": "spawn_pr", "args": {"direction": "EAST", "coord1_x": 6, "coord1_y": 5, "coord2_x": 6, "coord2_y": 9}},
	{"time": 9, "function": "spawn_pr", "args": {"direction": "WEST", "coord1_x": 14, "coord1_y": 5, "coord2_x": 14, "coord2_y": 9}},
	{"time": 13, "function": "spawn_pr", "args": {"direction": "NORTH", "coord1_x": 6, "coord1_y": 9, "coord2_x": 14, "coord2_y": 9, "coord3_x": 10, "coord3_y": 9}},
	# Drums enter 17
	{"time": 17, "function": "spawn_pr", "args": {"direction": "SOUTH", "coord1_x": 1, "coord1_y": 1, "coord2_x": 3, "coord2_y": 1}}, # Cascade SOUTH
	{"time": 18, "function": "spawn_pr", "args": {"direction": "SOUTH", "coord_x": 5, "coord_y": 1}},
	{"time": 19, "function": "spawn_pr", "args": {"direction": "SOUTH", "coord_x": 7, "coord_y": 1}},
	{"time": 20, "function": "spawn_pr", "args": {"direction": "SOUTH", "coord_x": 9, "coord_y": 1}},
	{"time": 21, "function": "spawn_pr", "args": {"direction": "SOUTH", "coord1_x": 11, "coord1_y": 1, "coord2_x": 13, "coord2_y": 1}},
	{"time": 22, "function": "spawn_pr", "args": {"direction": "SOUTH", "coord_x": 15, "coord_y": 1}},
	{"time": 23, "function": "spawn_pr", "args": {"direction": "SOUTH", "coord_x": 17, "coord_y": 1}},
	{"time": 24, "function": "spawn_pr", "args": {"direction": "SOUTH", "coord_x": 19, "coord_y": 1}},
	{"time": 25, "function": "spawn_pr", "args": {"direction": "NORTH", "coord1_x": 2, "coord1_y": 13, "coord2_x": 4, "coord2_y": 13}}, # Cascade NORTH
	{"time": 26, "function": "spawn_pr", "args": {"direction": "NORTH", "coord1_x": 6, "coord1_y": 13, "coord2_x": 8, "coord2_y": 13}},
	{"time": 27, "function": "spawn_pr", "args": {"direction": "NORTH", "coord1_x": 10, "coord1_y": 13, "coord2_x": 12, "coord2_y": 13}},
	{"time": 28, "function": "spawn_pr", "args": {"direction": "NORTH", "coord1_x": 14, "coord1_y": 13, "coord2_x": 16, "coord2_y": 13}},
	{"time": 29, "function": "spawn_pr", "args": {"direction": "NORTH", "coord1_x": 18, "coord1_y": 13, "coord2_x": 9, "coord2_y": 13, "coord3_x": 10, "coord3_y": 13, "coord4_x": 11, "coord4_y": 13, "coord5_x": 2, "coord5_y": 13}},
	# Bells enter 33
	{"time": 33, "function": "spawn_ghost_on_player", "args": {}}, # Bells attack
	{"time": 35, "function": "spawn_ghost_on_player", "args": {}},
	{"time": 37, "function": "spawn_ghost_on_player", "args": {}},
	{"time": 39, "function": "spawn_ghost_on_player", "args": {}},
	{"time": 41, "function": "spawn_pr", "args": {"direction": "EAST", "coord1_x": 5, "coord1_y": 3, "coord2_x": 5, "coord2_y": 5, "coord3_x": 5, "coord3_y": 7, "coord4_x": 5, "coord4_y": 9, "coord5_x": 5, "coord5_y": 11}},
	{"time": 42, "function": "spawn_pr", "args": {"direction": "WEST", "coord1_x": 15, "coord1_y": 3, "coord2_x": 15, "coord2_y": 5, "coord3_x": 15, "coord3_y": 7, "coord4_x": 15, "coord4_y": 9, "coord5_x": 15, "coord5_y": 11}},
	{"time": 43, "function": "spawn_pr", "args": {"direction": "SOUTH", "coord1_x": 6, "coord1_y": 1, "coord2_x": 8, "coord2_y": 1,  "coord3_x": 10, "coord3_y": 1,  "coord4_x": 12, "coord4_y": 1, "coord5_x": 14, "coord5_y": 1}},
	{"time": 45, "function": "spawn_pr", "args": {"direction": "NORTH", "coord1_x": 1, "coord1_y": 13, "coord2_x": 2, "coord2_y": 13, "coord3_x": 3, "coord3_y": 13, "coord4_x": 4, "coord4_y": 13, "coord5_x": 5, "coord5_y": 13}},
	{"time": 46, "function": "spawn_pr", "args": {"direction": "NORTH", "coord1_x": 15, "coord1_y": 13, "coord2_x": 16, "coord2_y": 13, "coord3_x": 17, "coord3_y": 13, "coord4_x": 18, "coord4_y": 13, "coord5_x": 19, "coord5_y": 13}},
	{"time": 49, "function": "spawn_pr", "args": {"direction": "EAST", "type": "SPINNING", "turn": "5", "coord_x": 1, "coord_y": 1}}, # Spirals start
	{"time": 52, "function": "spawn_pr", "args": {"direction": "WEST", "type": "SPINNING", "turn": "5", "coord_x": 5, "coord_y": 5}},
	{"time": 53, "function": "spawn_pr", "args": {"direction": "SOUTH", "type": "SPINNING", "turn": "5", "coord_x": 19, "coord_y": 1}},
	{"time": 56, "function": "spawn_pr", "args": {"direction": "NORTH", "type": "SPINNING", "turn": "5", "coord_x": 15, "coord_y": 5}},
	{"time": 57, "function": "spawn_pr", "args": {"direction": "WEST", "type": "SPINNING", "turn": "5", "coord_x": 19, "coord_y": 13}},
	{"time": 60, "function": "spawn_pr", "args": {"direction": "EAST", "type": "SPINNING", "turn": "5", "coord_x": 15, "coord_y": 9}},
	{"time": 61, "function": "spawn_pr", "args": {"direction": "NORTH", "type": "SPINNING", "turn": "5", "coord_x": 1, "coord_y": 13}},
	{"time": 64, "function": "spawn_pr", "args": {"direction": "SOUTH", "type": "SPINNING", "turn": "5", "coord_x": 5, "coord_y": 9}},
	# Bongos enter 65
	{"time": 65, "function": "spawn_ghost_on_player", "args": {}}, # Bells attack
	{"time": 67, "function": "spawn_ghost_on_player", "args": {}},
	{"time": 69, "function": "spawn_ghost_on_player", "args": {}},
	{"time": 71, "function": "spawn_ghost_on_player", "args": {}},
	{"time": 73, "function": "spawn_pr", "args": {"direction": "EAST", "coord1_x": 5, "coord1_y": 3, "coord2_x": 5, "coord2_y": 5, "coord3_x": 5, "coord3_y": 7, "coord4_x": 5, "coord4_y": 9, "coord5_x": 5, "coord5_y": 11}},
	{"time": 74, "function": "spawn_pr", "args": {"direction": "WEST", "coord1_x": 15, "coord1_y": 3, "coord2_x": 15, "coord2_y": 5, "coord3_x": 15, "coord3_y": 7, "coord4_x": 15, "coord4_y": 9, "coord5_x": 15, "coord5_y": 11}},
	{"time": 75, "function": "spawn_pr", "args": {"direction": "SOUTH", "coord1_x": 6, "coord1_y": 1, "coord2_x": 8, "coord2_y": 1,  "coord3_x": 10, "coord3_y": 1,  "coord4_x": 12, "coord4_y": 1, "coord5_x": 14, "coord5_y": 1}},
	{"time": 77, "function": "spawn_pr", "args": {"direction": "NORTH", "coord1_x": 1, "coord1_y": 13, "coord2_x": 2, "coord2_y": 13, "coord3_x": 3, "coord3_y": 13, "coord4_x": 4, "coord4_y": 13, "coord5_x": 5, "coord5_y": 13}},
	{"time": 78, "function": "spawn_pr", "args": {"direction": "NORTH", "coord1_x": 15, "coord1_y": 13, "coord2_x": 16, "coord2_y": 13, "coord3_x": 17, "coord3_y": 13, "coord4_x": 18, "coord4_y": 13, "coord5_x": 19, "coord5_y": 13}},
	{"time": 81, "function": "spawn_pr", "args": {"direction": "SOUTH", "coord1_x": 1, "coord1_y": 1, "coord2_x": 19, "coord2_y": 1}}, # Curtains SOUTH
	{"time": 82, "function": "spawn_pr", "args": {"direction": "SOUTH", "coord1_x": 2, "coord1_y": 1, "coord2_x": 18, "coord2_y": 1}},
	{"time": 83, "function": "spawn_pr", "args": {"direction": "SOUTH", "coord1_x": 3, "coord1_y": 1, "coord2_x": 17, "coord2_y": 1}},
	{"time": 84, "function": "spawn_pr", "args": {"direction": "SOUTH", "coord1_x": 4, "coord1_y": 1, "coord2_x": 16, "coord2_y": 1}},
	{"time": 85, "function": "spawn_pr", "args": {"direction": "SOUTH", "coord1_x": 5, "coord1_y": 1, "coord2_x": 15, "coord2_y": 1}},
	{"time": 86, "function": "spawn_pr", "args": {"direction": "SOUTH", "coord1_x": 6, "coord1_y": 1, "coord2_x": 14, "coord2_y": 1}},
	{"time": 87, "function": "spawn_pr", "args": {"direction": "SOUTH", "coord1_x": 7, "coord1_y": 1, "coord2_x": 13, "coord2_y": 1}},
	{"time": 88, "function": "spawn_pr", "args": {"direction": "SOUTH", "coord1_x": 8, "coord1_y": 1, "coord2_x": 12, "coord2_y": 1}},
	{"time": 89, "function": "spawn_pr", "args": {"direction": "SOUTH", "coord1_x": 9, "coord1_y": 1, "coord2_x": 11, "coord2_y": 1}},
	{"time": 90, "function": "spawn_pr", "args": {"direction": "SOUTH", "coord_x": 10, "coord_y": 1}},
	
	# Bongos repeat 97
	{"time": 97, "function": "spawn_pr", "args": {"direction": "EAST", "coord1_x": 1, "coord1_y": 1, "coord2_x": 1, "coord2_y": 2}}, # Cascade EAST
	{"time": 98, "function": "spawn_pr", "args": {"direction": "EAST", "coord1_x": 1, "coord1_y": 3, "coord2_x": 1, "coord2_y": 4}},
	{"time": 99, "function": "spawn_pr", "args": {"direction": "EAST", "coord1_x": 1, "coord1_y": 5, "coord2_x": 1, "coord2_y": 6}},
	{"time": 100, "function": "spawn_pr", "args": {"direction": "EAST", "coord1_x": 1, "coord1_y": 7, "coord2_x": 1, "coord2_y": 8}},
	{"time": 101, "function": "spawn_pr", "args": {"direction": "EAST", "coord1_x": 1, "coord1_y": 9, "coord2_x": 1, "coord2_y": 10}},
	{"time": 102, "function": "spawn_pr", "args": {"direction": "EAST", "coord1_x": 1, "coord1_y": 11, "coord2_x": 1, "coord2_y": 12}},
	{"time": 109, "function": "spawn_pr", "args": {"direction": "NORTH", "coord1_x": 1, "coord1_y": 13, "coord2_x": 2, "coord2_y": 13, "coord3_x": 3, "coord3_y": 13, "coord4_x": 4, "coord4_y": 13, "coord5_x": 5, "coord5_y": 13}},
	{"time": 110, "function": "spawn_pr", "args": {"direction": "NORTH", "coord1_x": 15, "coord1_y": 13, "coord2_x": 16, "coord2_y": 13, "coord3_x": 17, "coord3_y": 13, "coord4_x": 18, "coord4_y": 13, "coord5_x": 19, "coord5_y": 13}},
	{"time": 113, "function": "spawn_ghost_on_player", "args": {}}, # Ghost bells attack 2
	{"time": 115, "function": "spawn_ghost_on_player", "args": {}},
	{"time": 116, "function": "spawn_ghost_on_player", "args": {}},
	{"time": 117, "function": "spawn_ghost_on_player", "args": {}},
	{"time": 120, "function": "spawn_ghost_on_player", "args": {}}, # Ghost bells attack 2
	{"time": 122, "function": "spawn_ghost_on_player", "args": {}},
	{"time": 123, "function": "spawn_ghost_on_player", "args": {}},
	{"time": 124, "function": "spawn_ghost_on_player", "args": {}},
	# Synthy part 129
	{"time": 129, "function": "spawn_pr", "args": {"type": "EXPANDING", "coord_x": 5, "coord_y": 5}}, # EXpanding corners attack
	{"time": 137, "function": "spawn_pr", "args": {"direction": "WEST", "type": "EXPANDING", "coord_x": 15, "coord_y": 10}},
	{"time": 145, "function": "spawn_pr", "args": {"direction": "WEST", "type": "EXPANDING", "coord_x": 15, "coord_y": 5}},
	{"time": 153, "function": "spawn_pr", "args": {"direction": "WEST", "type": "EXPANDING", "coord_x": 5, "coord_y": 10}},
	# Trail off 161
	
]
var next_event: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Dialogic.start("supernatural_dialogic")
	Dialogic.signal_event.connect(_ready_post_dialog)
	
	telegraph = dash_telegraph.instantiate()
	add_child(telegraph)
	
	#dash_telegraph_rect = ColorRect.new()
	#dash_telegraph_rect.color = Color(68, 85, 120, 0.7)  # Semi-transparent light blue
	#add_child(dash_telegraph_rect)

func _ready_post_dialog(arg: String):
	# Declare a function to be executed whenever the quarter_beat signal is emitted
	Conductor.quarter_beat.connect(_on_quarter_beat)
	window_dimensions =  GameState.control_port.size
	GameEvents.game_start.emit()
	
	%Player.position = GameState.control_port.get_center()
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
		cleave.position = GameState.control_port.get_center()
		cleave.position += randi_range(-5,5) * Vector2(TILE_SIZE, TILE_SIZE)
	# start() depends on being added to tree beforehand
	cleave.start(direction)
	

func spawn_ghost_on_player(args: Dictionary):
	var ghost = spawn_ghost.instantiate()
	ghost.position = %Player.position
	add_child(ghost)


# Can spawn up to 5 projectiles at athe same time currently
func spawn_pr(args: Dictionary):
	var projectile = spawn_projectile.instantiate()
	var type  = args.type if args.has("type") else ""
	var direction  = args.direction if args.has("direction") else ""
	var turn_count = int(args.turn) if args.has("turn") else 0
	var coords
	
	# TODO: Abstract if possible, maybe rename coordinates to "cx_1", "cy_1" and then use a for loop
		#for n in 8: 
			#if (args.has("cx_" + str(n)) && args.has("cy_" + str(n)):
				#coords.append(Vector2(int(args.c # Here is where the problem would be
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
	elif (args.has("coord_x") && args.has("coord_y")): # TODO: remove this and just use coord1?
		coords = Vector2(int(args.coord_x), int(args.coord_y))
	else:
		coords = Vector2(0, 0) # Default
	add_child(projectile)
	projectile.start_one_coord(direction, type, coords, turn_count)
	

func spawn_pr_random(args: Dictionary):
	var projectile = spawn_projectile.instantiate()
	var type  = args.type if args.has("type") else ""
	var direction  = args.direction if args.has("direction") else ""
	var coords = get_random_position()
	var turn_count = int(args.turn) if args.has("turn") else 2
	add_child(projectile)
	projectile.start_one_coord(direction, type, coords, turn_count)



func _on_player_spawn_afterimage(player_pos: Vector2) -> void:
	var afterimage = spawn_afterimage.instantiate()
	afterimage.position = player_pos
	add_child(afterimage)
	


func _on_player_update_telegraph(player_pos: Vector2, charges: float, direction: Vector2) -> void:	
	var centered_player_pos = player_pos - Vector2(dash_telegraph_rect_size / 2, dash_telegraph_rect_size / 2)
	var chosen_start_pos = player_pos # Can choose: rectangle = use centered, scene = use player_pos
	
	var telegraph_pos
	if (floor(charges) == 1):
		telegraph_pos = chosen_start_pos + direction * 3 * TILE_SIZE;
	elif (floor(charges) == 2):
		telegraph_pos = chosen_start_pos + direction * 6 * TILE_SIZE;
	else:
		telegraph_pos = chosen_start_pos
	
	# Code if Using Rectangle
	#dash_telegraph_rect.position = telegraph_pos
	#if (floor(charges) == 0):
		#dash_telegraph_rect.size = Vector2(0, 0)
	#else:
		#dash_telegraph_rect.size = Vector2(dash_telegraph_rect_size, dash_telegraph_rect_size)
	
	# Code if Using Dash Telegraph Scene
	telegraph.position = telegraph_pos
	if (floor(charges) == 0):
		telegraph.visible = false
	else:
		telegraph.visible = true
