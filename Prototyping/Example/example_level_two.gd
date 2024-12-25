extends Node2D

@onready var player := $Player
@onready var hud := $HUD

@export var half_room_cleave: PackedScene
@export var ghost: PackedScene
@export var alert_sign: PackedScene

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

var to_reset_hazards: bool = false
var to_reset_ghosts: bool = false

#var ghost = {
	#"position": Vector2(0,0),
	#"active": false,
#}

# A queue of scheduled function calls.
# 	'time' is measured in beats; must be strictly non-decreasing
#   'function' is the name of a function in this script; must be in quotation marks
var timeline = [
	{"time": 1, "function": "spawn_ghost_on_player"},
	{"time": 4, "function": "spawn_ghost_on_player"},
	{"time": 8, "function": "cleave_left"},
	{"time": 14, "function": "spawn_ghost_on_player"},
	{"time": 20, "function": "spawn_ghost_on_player"},
	{"time": 24, "function": "cleave_left"},
	{"time": 25, "function": "spawn_ghost_on_player"},
	{"time": 30, "function": "spawn_ghost_on_player"},
]
# Index into the timeline
var next_event: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Declare a function to be executed whenever the quarter_beat signal is emitted
	Conductor.quarter_beat.connect(_on_quarter_beat)
	window_dimensions =  get_viewport_rect().size
	pass


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
		call(timeline[next_event].function)
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


func cleave_left():
	var cleave = half_room_cleave.instantiate()
	add_child(cleave)


func spawn_ghost_on_player():
	var telegraph = alert_sign.instantiate()
	telegraph.position = %Player.position
	add_child(telegraph)
	
	var spawn_timer = Timer.new()
	spawn_timer.wait_time = 4 * Conductor.seconds_per_quarter_note
	# Call the function with player's position at the time of creating timer
	spawn_timer.timeout.connect(_on_ghost_spawn_timeout.bind(%Player.position, telegraph))
	spawn_timer.one_shot = true
	telegraph.add_child(spawn_timer)
	spawn_timer.start()


func _on_ghost_spawn_timeout(position: Vector2, telegraph):
	var enemy = ghost.instantiate()
	enemy.position = position
	add_child(enemy)
	
	# Have the ghost automatically despawn after a while
	var despawn_timer = Timer.new()
	despawn_timer.one_shot = true
	despawn_timer.wait_time = 5 * Conductor.seconds_per_quarter_note
	despawn_timer.timeout.connect(enemy.queue_free)
	enemy.add_child(despawn_timer)
	despawn_timer.start()
	
	print(telegraph)
	telegraph.queue_free()
