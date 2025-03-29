extends Node2D

@onready var player := $Player
@onready var hud := $HUD
@onready var staff := %BossStaff

@export var half_room_cleave: PackedScene
@export var spawn_ghost: PackedScene
@export var puddle_hazard: PackedScene
@export var thunderstorm: PackedScene
@export var iterative_projectile: PackedScene
@export var vine_cross: PackedScene
@export var spawn_afterimage: PackedScene

@export var debug_random_test: bool = false
var GameOverComponent = preload("res://UI/GameOver.tscn")
var VictoryComponent = preload("res://UI/Victory.tscn")

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
	{"time": 1, "function": "slow_cleave", "args": {}},
	{"time": 2, "function": "thunderstorm_telegraph", "args": {}},
	{"time": 4, "function": "spawn_thunderstorm", "args": {}},
	{"time": 18, "function": "spawn_vine_cage", "args": {}},
	{"time": 22, "function": "spawn_puddles_periodically", "args": {}},
	{"time": 38, "function": "thunderstorm_telegraph", "args": {}},
	{"time": 40, "function": "spawn_thunderstorm", "args": {}},
	{"time": 54, "function": "spawn_flame_wall", "args": {"position": Vector2(112,272)}},
	{"time": 56, "function": "spawn_flame_wall", "args": {"position": Vector2(240,272)}},
	{"time": 58, "function": "spawn_flame_wall", "args": {"position": Vector2(368,272)}},
	{"time": 60, "function": "spawn_flame_wall", "args": {"position": Vector2(496,272)}},
	{"time": 64, "function": "cleave", "args": {"direction": "SOUTH"}},
	{"time": 68, "function": "cleave", "args": {"direction": "NORTH"}},
	{"time": 76, "function": "cleave", "args": {"direction": "EAST"}},
	{"time": 84, "function": "spawn_vine_cage", "args": {}},
	{"time": 88, "function": "slow_cleave", "args": {}},
	{"time": 96, "function": "slow_cleave", "args": {}},
	
]
var next_event: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Dialogic.start("fantasy_dialogic")
	Dialogic.signal_event.connect(_ready_post_dialog)
	Conductor.set_music("Fantasy1")
	
	# Change sprite to Wizard
	%Player.player_sprite.sprite_frames = load("res://Player/fantasy_sprite_frames.tres")

func _ready_post_dialog(arg: String):
	# Declare a function to be executed whenever the quarter_beat signal is emitted
	Conductor.quarter_beat.connect(_on_quarter_beat)
	Conductor.song_finished.connect(_on_song_finished)
	GameEvents.player_died.connect(_on_player_died)
	GameEvents.game_start.emit()
	window_dimensions =  GameState.control_port.size
	
	%Player.position = GameState.control_port.get_center()
	%Player.spawn_afterimage.connect(_on_player_spawn_afterimage)
	Conductor.set_music("Fantasy2")
	$HUD.start_beat_indicator()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass;

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
	# Player wins automatically if they make it to the end. Score is a bonus.
	var victory = VictoryComponent.instantiate()
	Dialogic.start("fantasy_closing_dialog")
	await Dialogic.timeline_ended
	add_child(victory)

func _on_player_died():
	# TODO: Despawn player, stop processing input
	timeline = []
	var game_over = GameOverComponent.instantiate()
	add_child(game_over)
	Conductor.stop_music()

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
	
	if args.has("telegraph_duration"):
		cleave.set_telegraph_duration(args.telegraph_duration)
	
	# Add first, because start() depends on being added to tree 
	add_child(cleave)
	if debug_random_test:
		cleave.position = GameState.control_port.get_center()
		cleave.position += randi_range(-5,5) * Vector2(TILE_SIZE, TILE_SIZE)
	cleave.start(direction)
	
# telegraphs the thunderstorm by playing staff animation
func thunderstorm_telegraph(args: Dictionary):
	staff.anim.play("call_lightning")
	
	
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
	
func spawn_flame_wall(args: Dictionary):
	var pos = args.position if args.has("position") else Vector2(112, 272)
	var puddle = puddle_hazard.instantiate()
	puddle.position = pos
	puddle.set_dimensions(Vector2(4, 14))
	add_child(puddle)
	puddle.start()

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

func spawn_vine_cross(coords: Vector2):
	#var coords = args.coords if args.has("coords") else Vector2(10, 7)
	var cross = vine_cross.instantiate()
	cross.position = coords * 32
	add_child(cross)
	
# Spawn 3x3 of vine crosses, centered on middle of arena.
func spawn_vine_cage(args: Dictionary):
	var center_y: int = 7
	var center_x: int = 10
	var offset_x: int = 6
	var offset_y: int = 4

	for x in [center_x-offset_x, center_x, center_x+offset_x]:
		for y in [center_y-offset_y, center_y, center_y+offset_y]:
			spawn_vine_cross(Vector2(x,y))
			
func slow_cleave(args: Dictionary):
	# TODO: Always pick direction that includes player.
	
	# Must be ordered 90 degrees apart, so cleaves never occupy entire arena
	const cardinals = ["NORTH", "EAST", "SOUTH", "WEST"]
	
	var random_index = randi_range(0, len(cardinals)-1)
	var rotated_index = (random_index + 1) % len(cardinals)

	cleave({"direction": cardinals[random_index], "telegraph_duration": 8})
	cleave({"direction": cardinals[rotated_index], "telegraph_duration": 8})


func _on_quarter_beat_spawn_puddle(beat_num: int):
	var beats_passed = floori(Conductor.num_beats_passed)
	# Only every four beats, starting on beat two of a measure
	if beats_passed % 4 != 2 or beats_passed > 50:
		return
		
	#print("Spawning puddle")
	var puddle = puddle_hazard.instantiate()
	puddle.position = %Player.position
	add_child(puddle)
	if debug_random_test:
		var random_width = randi_range(3,6)
		# Always square, just for testing
		puddle.set_dimensions(Vector2(random_width, random_width-1))
		puddle.position = GameState.control_port.get_center()
		puddle.position += randi_range(-5,5) * Vector2(TILE_SIZE, TILE_SIZE)
	puddle.start()

func _on_player_spawn_afterimage(player_pos: Vector2) -> void:
	var afterimage = spawn_afterimage.instantiate()
	afterimage.set_image($Player.player_sprite)
	afterimage.position = player_pos
	add_child(afterimage)
