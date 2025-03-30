extends Node2D

@onready var player := $Player
@onready var hud := $HUD

@export var half_room_cleave: PackedScene # TODO remove?
@export var spawn_ghost: PackedScene
@export var spawn_projectile: PackedScene
@export var spawn_afterimage: PackedScene
@export var dash_telegraph: PackedScene
@export var debug_random_test: bool = false
@export var cont_projectile_manager: PackedScene
@export var itr_projectile_manager: PackedScene

var GameOverComponent = preload("res://UI/GameOver.tscn")
var VictoryComponent = preload("res://UI/Victory.tscn")

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

# A queue of scheduled function calls.
# 	'time' is measured in beats; must be strictly non-decreasing
#   'function' is the name of a function in this script; must be in quotation marks
# 	'args' is a dictionary of additional parameters to 'function'
var timeline = [
	# Intro
	{"time": 1, "function": "spawn_pr_cont", "args": {"direction": "DOWN", "coord1": Vector2i(6, 5), "coord2": Vector2i(14, 5)}},
	{"time": 5, "function": "spawn_pr_cont", "args": {"direction": "RIGHT", "coord1": Vector2i(6, 5), "coord2": Vector2i(6, 9)}},
	{"time": 9, "function": "spawn_pr_cont", "args": {"direction": "LEFT", "coord1": Vector2i(14, 5), "coord2": Vector2i(14, 9)}},
	{"time": 13, "function": "spawn_pr_cont", "args": {"direction": "UP", "coord1": Vector2i(6, 9), "coord2": Vector2i(14, 9), "coord3": Vector2i(10, 9)}},
	## Drums enter 17
	{"time": 17, "function": "spawn_pr_cont", "args": {"direction": "DOWN", "coord1": Vector2i(1, 1), "coord2": Vector2i(3, 1)}}, # Cascade DOWN
	{"time": 18, "function": "spawn_pr_cont", "args": {"direction": "DOWN", "coord1": Vector2i(5, 1)}},
	{"time": 19, "function": "spawn_pr_cont", "args": {"direction": "DOWN", "coord1": Vector2i(7, 1)}},
	{"time": 20, "function": "spawn_pr_cont", "args": {"direction": "DOWN", "coord1": Vector2i(9, 1)}},
	{"time": 21, "function": "spawn_pr_cont", "args": {"direction": "DOWN", "coord1": Vector2i(11, 1), "coord2": Vector2i(13, 1)}},
	{"time": 22, "function": "spawn_pr_cont", "args": {"direction": "DOWN", "coord1": Vector2i(15, 1)}},
	{"time": 23, "function": "spawn_pr_cont", "args": {"direction": "DOWN", "coord1": Vector2i(17, 1)}},
	{"time": 24, "function": "spawn_pr_cont", "args": {"direction": "DOWN", "coord1": Vector2i(19, 1)}},
	{"time": 25, "function": "spawn_pr_cont", "args": {"direction": "UP", "coord1": Vector2i(2, 13), "coord2": Vector2i(4, 13)}}, # Cascade UP
	{"time": 26, "function": "spawn_pr_cont", "args": {"direction": "UP", "coord1": Vector2i(6, 13), "coord2": Vector2i(8, 13)}},
	{"time": 27, "function": "spawn_pr_cont", "args": {"direction": "UP", "coord1": Vector2i(10, 13), "coord2": Vector2i(12, 13)}},
	{"time": 28, "function": "spawn_pr_cont", "args": {"direction": "UP", "coord1": Vector2i(14, 13), "coord2": Vector2i(16, 13)}},
	{"time": 29, "function": "spawn_pr_cont", "args": {"direction": "UP", "coord1": Vector2i(18, 13), "coord2": Vector2i(20, 13), "coord3": Vector2i(9, 13), "coord4": Vector2i(10, 13), "coord5": Vector2i(11, 13)}},
	## Bells enter 33
	{"time": 33, "function": "spawn_ghost_on_player", "args": {}}, # Bells attack
	{"time": 35, "function": "spawn_ghost_on_player", "args": {}},
	{"time": 37, "function": "spawn_ghost_on_player", "args": {}},
	{"time": 39, "function": "spawn_ghost_on_player", "args": {}},
	{"time": 41, "function": "spawn_pr_cont", "args": {"direction": "RIGHT", "coord1": Vector2i(5, 3), "coord2": Vector2i(5, 5), "coord3": Vector2i(5, 7), "coord4": Vector2i(5, 9), "coord5": Vector2i(5, 11)}},
	{"time": 42, "function": "spawn_pr_cont", "args": {"direction": "LEFT", "coord1": Vector2i(15, 3), "coord2": Vector2i(15, 5), "coord3": Vector2i(15, 7), "coord4": Vector2i(15, 9), "coord5": Vector2i(15, 11)}},
	{"time": 43, "function": "spawn_pr_cont", "args": {"direction": "DOWN", "coord1": Vector2i(6, 1), "coord2": Vector2i(8, 1), "coord3": Vector2i(10, 1), "coord4": Vector2i(12, 1), "coord5": Vector2i(14, 1)}},
	{"time": 45, "function": "spawn_pr_cont", "args": {"direction": "UP", "coord1": Vector2i(1, 13), "coord2": Vector2i(2, 13), "coord3": Vector2i(3, 13), "coord4": Vector2i(4, 13), "coord5": Vector2i(5, 13)}},
	{"time": 46, "function": "spawn_pr_cont", "args": {"direction": "UP", "coord1": Vector2i(15, 13), "coord2": Vector2i(16, 13), "coord3": Vector2i(17, 13), "coord4": Vector2i(18, 13), "coord5": Vector2i(19, 13)}},
	{"time": 50, "function": "spawn_pr", "args": {"type": "EXPANDING", "coord1": Vector2i(10, 7)}},
	## Bongos enter 65
	{"time": 65, "function": "spawn_ghost_on_player", "args": {}}, # Bells attack
	{"time": 67, "function": "spawn_ghost_on_player", "args": {}},
	{"time": 69, "function": "spawn_ghost_on_player", "args": {}},
	{"time": 71, "function": "spawn_ghost_on_player", "args": {}},
	{"time": 73, "function": "spawn_pr_cont", "args": {"direction": "RIGHT", "coord1": Vector2i(5, 3), "coord2": Vector2i(5, 5), "coord3": Vector2i(5, 7), "coord4": Vector2i(5, 9), "coord5": Vector2i(5, 11)}},
	{"time": 74, "function": "spawn_pr_cont", "args": {"direction": "LEFT", "coord1": Vector2i(15, 3), "coord2": Vector2i(15, 5), "coord3": Vector2i(15, 7), "coord4": Vector2i(15, 9), "coord5": Vector2i(15, 11)}},
	{"time": 75, "function": "spawn_pr_cont", "args": {"direction": "DOWN", "coord1": Vector2i(6, 1), "coord2": Vector2i(8, 1), "coord3": Vector2i(10, 1), "coord4": Vector2i(12, 1), "coord5": Vector2i(14, 1)}},
	{"time": 77, "function": "spawn_pr_cont", "args": {"direction": "UP", "coord1": Vector2i(1, 13), "coord2": Vector2i(2, 13), "coord3": Vector2i(3, 13), "coord4": Vector2i(4, 13), "coord5": Vector2i(5, 13)}},
	{"time": 78, "function": "spawn_pr_cont", "args": {"direction": "UP", "coord1": Vector2i(15, 13), "coord2": Vector2i(16, 13), "coord3": Vector2i(17, 13), "coord4": Vector2i(18, 13), "coord5": Vector2i(19, 13)}},
	{"time": 81, "function": "spawn_pr_cont", "args": {"direction": "DOWN", "coord1": Vector2i(1, 1), "coord2": Vector2i(19, 1)}}, # Curtains DOWN
	{"time": 82, "function": "spawn_pr_cont", "args": {"direction": "DOWN", "coord1": Vector2i(2, 1), "coord2": Vector2i(18, 1)}},
	{"time": 83, "function": "spawn_pr_cont", "args": {"direction": "DOWN", "coord1": Vector2i(3, 1), "coord2": Vector2i(17, 1)}},
	{"time": 84, "function": "spawn_pr_cont", "args": {"direction": "DOWN", "coord1": Vector2i(4, 1), "coord2": Vector2i(16, 1)}},
	{"time": 85, "function": "spawn_pr_cont", "args": {"direction": "DOWN", "coord1": Vector2i(5, 1), "coord2": Vector2i(15, 1)}},
	{"time": 86, "function": "spawn_pr_cont", "args": {"direction": "DOWN", "coord1": Vector2i(6, 1), "coord2": Vector2i(14, 1)}},
	{"time": 87, "function": "spawn_pr_cont", "args": {"direction": "DOWN", "coord1": Vector2i(7, 1), "coord2": Vector2i(13, 1)}},
	{"time": 88, "function": "spawn_pr_cont", "args": {"direction": "DOWN", "coord1": Vector2i(8, 1), "coord2": Vector2i(12, 1)}},
	{"time": 89, "function": "spawn_pr_cont", "args": {"direction": "DOWN", "coord1": Vector2i(9, 1), "coord2": Vector2i(11, 1)}},
	{"time": 90, "function": "spawn_pr_cont", "args": {"direction": "DOWN", "coord1": Vector2i(10, 1)}},

	## Bongos repeat 97
	{"time": 97, "function": "spawn_pr_cont", "args": {"direction": "RIGHT", "coord1": Vector2i(1, 1), "coord2": Vector2i(1, 2)}}, # Cascade RIGHT
	{"time": 98, "function": "spawn_pr_cont", "args": {"direction": "RIGHT", "coord1": Vector2i(1, 3), "coord2": Vector2i(1, 4)}},
	{"time": 99, "function": "spawn_pr_cont", "args": {"direction": "RIGHT", "coord1": Vector2i(1, 5), "coord2": Vector2i(1, 6)}},
	{"time": 100, "function": "spawn_pr_cont", "args": {"direction": "RIGHT", "coord1": Vector2i(1, 7), "coord2": Vector2i(1, 8)}},
	{"time": 101, "function": "spawn_pr_cont", "args": {"direction": "RIGHT", "coord1": Vector2i(1, 9), "coord2": Vector2i(1, 10)}},
	{"time": 102, "function": "spawn_pr_cont", "args": {"direction": "RIGHT", "coord1": Vector2i(1, 11), "coord2": Vector2i(1, 12)}},
	{"time": 109, "function": "spawn_pr_cont", "args": {"direction": "UP", "coord1": Vector2i(1, 13), "coord2": Vector2i(2, 13), "coord3": Vector2i(3, 13), "coord4": Vector2i(4, 13), "coord5": Vector2i(5, 13)}},
	{"time": 110, "function": "spawn_pr_cont", "args": {"direction": "UP", "coord1": Vector2i(15, 13), "coord2": Vector2i(16, 13), "coord3": Vector2i(17, 13), "coord4": Vector2i(18, 13), "coord5": Vector2i(19, 13)}},
	{"time": 113, "function": "spawn_ghost_on_player", "args": {}}, # Ghost bells attack 2
	{"time": 115, "function": "spawn_ghost_on_player", "args": {}},
	{"time": 116, "function": "spawn_ghost_on_player", "args": {}},
	{"time": 117, "function": "spawn_ghost_on_player", "args": {}},
	{"time": 120, "function": "spawn_ghost_on_player", "args": {}}, # Ghost bells attack 2
	{"time": 122, "function": "spawn_ghost_on_player", "args": {}},
	{"time": 123, "function": "spawn_ghost_on_player", "args": {}},
	{"time": 124, "function": "spawn_ghost_on_player", "args": {}},
	
	{"time": 129, "function": "spawn_pr", "args": {"type": "EXPANDING", "coord1": Vector2i(5, 5)}}, # Expanding corners attack
	{"time": 137, "function": "spawn_pr", "args": {"type": "EXPANDING", "coord1": Vector2i(15, 10)}},
	{"time": 145, "function": "spawn_pr", "args": {"type": "EXPANDING", "coord1": Vector2i(15, 5)}},
	{"time": 153, "function": "spawn_pr", "args": {"type": "EXPANDING", "coord1": Vector2i(5, 10)}},
	
]
var next_event: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Dialogic.start("supernatural_dialogic")
	Dialogic.signal_event.connect(_ready_post_dialog)
	
	telegraph = dash_telegraph.instantiate()
	add_child(telegraph)
	Conductor.set_music("Supernatural2")
	
	# Change sprite to Supernatural character
	%Player.player_sprite.sprite_frames = load("res://Player/supernatural_sprite_frames.tres")

func _ready_post_dialog(arg: String):
	# Declare a function to be executed whenever the quarter_beat signal is emitted
	Conductor.quarter_beat.connect(_on_quarter_beat)
	Conductor.song_finished.connect(_on_song_finished)
	GameEvents.player_died.connect(_on_player_died)
	window_dimensions =  GameState.control_port.size
	GameEvents.game_start.emit()
	
	%Player.position = GameState.control_port.get_center()
	Conductor.set_music("Supernatural1")
	$HUD.start_beat_indicator()

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


# TODO: move this to projectile manager?
func spawn_pr(args: Dictionary):
	var projectile = itr_projectile_manager.instantiate()
	var type  = args.type if args.has("type") else ""
	var direction  = args.direction if args.has("direction") else ""
	var turn_count = int(args.turn) if args.has("turn") else 0
	var coords = PackedVector2Array()

	for i in range(1, 6):  # Adjust if needed
		var coord_key = "coord" + str(i)
		if args.has(coord_key):
			coords.append(args[coord_key])
	
	for i in range(1, 6):  # Adjust if needed
		var x_key = "coord" + str(i) + "_x"
		var y_key = "coord" + str(i) + "_y"
		if args.has(x_key) and args.has(y_key):
			coords.append(Vector2(int(args[x_key]), int(args[y_key])))

	if coords.is_empty():
		coords.append(Vector2(0, 0)) # default for badly defined coordinates
	
	add_child(projectile)
	projectile.start(direction, type, coords, turn_count)
	

func spawn_pr_random(args: Dictionary):
	var projectile = spawn_projectile.instantiate()
	var type  = args.type if args.has("type") else ""
	var direction  = args.direction if args.has("direction") else ""
	var coords = get_random_position()
	var turn_count = int(args.turn) if args.has("turn") else 2
	add_child(projectile)
	projectile.start_one_coord(direction, type, coords, turn_count)
	
	
func spawn_pr_cont(args: Dictionary):
	var prm = cont_projectile_manager.instantiate()
	var direction = args.direction if args.has("direction") else "DOWN"
	var type  = args.type if args.has("type") else 0
	var coords = PackedVector2Array()
	
	for i in range(1, 6):  # Adjust if needed
		var coord_key = "coord" + str(i)
		if args.has(coord_key):
			coords.append(args[coord_key])
	
	add_child(prm)
	prm.spawn_projectiles(type, coords, direction)


func _on_player_spawn_afterimage(player_pos: Vector2) -> void:
	var afterimage = spawn_afterimage.instantiate()
	afterimage.set_image($Player.player_sprite)
	afterimage.position = player_pos
	add_child(afterimage)
	


func _on_player_update_telegraph(player_pos: Vector2, charges: float, direction: Vector2) -> void:	
	var centered_player_pos = player_pos - Vector2(dash_telegraph_rect_size / 2, dash_telegraph_rect_size / 2)
	var chosen_start_pos = player_pos # Can choose: rectangle = use centered, scene = use player_pos
	
	var telegraph_pos
	if (floor(charges) == 1):
		telegraph_pos = chosen_start_pos + direction * 3 * TILE_SIZE;
		_update_zz_telegraph(-direction * 3 * TILE_SIZE, direction)
	elif (floor(charges) == 2):
		telegraph_pos = chosen_start_pos + direction * 6 * TILE_SIZE;
		_update_zz_telegraph(-direction * 6 * TILE_SIZE, direction)
	else:
		telegraph_pos = chosen_start_pos
		_update_zz_telegraph(Vector2(0,0), direction)
	
	# Code if Using Dash Telegraph Scene
	telegraph.position = telegraph_pos
	
	if (floor(charges) == 0):
		telegraph.visible = false
	else:
		telegraph.visible = true

func _update_zz_telegraph(player_offset: Vector2, direction: Vector2):
	#telegraph.get_node("Line2D").clear_points()
	## Redraw zig zags every time
	#var count = abs(max(player_offset.ax, player_offset.y)/TILE_SIZE)
	#
	#while (count > 0): # construct line backwards
		#var end_position = player_offseaaaaaaaaaaaaat - Vector2(count * TILE_SIZE)
		#telegraph.get_node("Line2D").add_point(end_position)
		#telegraph.get_node("Line2D").add_point(end_position - Vector2(-8, 0))
		#telegraph.get_node("Line2D").add_point(end_position - Vector2(-12, -16))
		#telegraph.get_node("Line2D").add_point(end_position - Vector2(-16, 0))
		#telegraph.get_node("Line2D").add_point(end_position - Vector2(-20, 16))
		#telegraph.get_node("Line2D").add_point(end_position - Vector2(-24, 0))
		#
		#count -= 1
		
	#telegraph.get_node("Line2D").add_point(Vector2(0,0))
	#telegraph.get_node("Line2D").set_point_position(1, player_offset)
	telegraph.get_node("Line2D").player_offset = player_offset
	telegraph.get_node("Line2D").direction = direction
	
	

func _on_song_finished():
	var victory = VictoryComponent.instantiate()
	add_child(victory)

func _on_player_died():
	# TODO: Despawn player, stop processing input
	timeline = []
	var game_over = GameOverComponent.instantiate()
	add_child(game_over)
	Conductor.stop_music()
