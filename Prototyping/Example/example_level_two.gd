extends Node2D

@onready var player := $Player
@onready var hud := $HUD

# TODO: Remove this reference
@onready var floor := $Floor

# TODO: Represent hazards as node (e.g. AlertSign) instead of a TileMapLayer
# Why? For better animations later on
@onready var hazards := $Hazards

# TODO: Represent ghosts as their own nodes (i.e. Ghost) instead of a TileMapLayer
# Why? For AI behaviours
@onready var ghost_map := $Ghost

@export var half_room_cleave: PackedScene

signal update_HUD(score: int, life: int)

var window_dimensions: Vector2
const WIDTH: int = 640
const HEIGHT: int = 448
const TILE_SIZE: int = 32
const HOR_TILES: int = WIDTH / TILE_SIZE
const VER_TILES: int = HEIGHT / TILE_SIZE
const TILES = {
	"RED": {"src": 2, "atlas": Vector2(0,0), "alt": 3},
	"DANGER": {"src": 3, "atlas": Vector2(0, 0), "alt": 0},
	"FLOOR_DARK": {"src": 1, "atlas": Vector2(0,0), "alt": 3},
	"FLOOR_MED": {"src": 1, "atlas": Vector2(0,0), "alt": 1},
	"FLOOR_LIGHT": {"src": 1, "atlas": Vector2(0,0), "alt": 0},
	"GHOST": {"src": 0, "atlas": Vector2(0, 0), "alt": 0},
}
const DEFAULT_FLOOR = TILES.FLOOR_DARK

var score: int = 0
var life: int = 10
var to_reset_hazards: bool = false
var to_reset_ghosts: bool = false

var ghost = {
	"position": Vector2(0,0),
	"active": false,
}

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
	score += 1
	update_HUD.emit(score, life)
	
	if int(Conductor.num_beats_passed) % 8 == 4:
		var cleave = half_room_cleave.instantiate()
		add_child(cleave)
		
	
	# TODO: Uncomment this after refactoring
	# update_boss()


func _on_eighth_beat(_beat_num: int):
	pass


## You can add scenes dynamically via GDScript code
#func spawn_danger_sign_at_random_location():
	## First, load the asset
	#var danger_sign = load("res://Prototyping/Marcus/Scenes/DangerSign.tscn")
	## Then, instantiate it
	#var danger_sign_instance = danger_sign.instantiate()
#
	## Set whatever parameters you need to
	#danger_sign_instance.position = get_random_position()
#
	## You must add it to the scene tree as well (in this case, a child of ExampleLevel)
	#add_child(danger_sign_instance)


func spawn_danger_sign_on_player():
	#hazards.set_cell(player.position/TILE_SIZE, 3, Vector2(0, 0), 0)
	set_hazard_tile(player.position/TILE_SIZE, TILES.DANGER)
	to_reset_hazards = true
	
	ghost.position = player.position / TILE_SIZE
	ghost.active = true

# 

func get_random_position() -> Vector2:
	
	# Create a random x and y for the danger sign
	# randi_range gets random integer within the range of tiles within the walls
	# x and y are scaled up, and add adjustment to align danger sign 
	# b/c danger sign position x,y is at its center, not its top left corner
	var random_x = randi_range(1, HOR_TILES - 2) * TILE_SIZE + TILE_SIZE/2
	var random_y = randi_range(1, VER_TILES - 2) * TILE_SIZE + TILE_SIZE/2
	
	return Vector2(random_x, random_y)


# TODO: Define a dictionary of steps to represent timeline
func update_boss():
	if to_reset_hazards:
		reset_hazards()
		to_reset_hazards = false
	
	if score in range(7, 8):
		cleave_left(TILES.DANGER)
	elif score in range(9, 12):
		cleave_left(TILES.RED)
		to_reset_hazards = true
	
	if score in range (15, 16):
		cleave_right(TILES.DANGER)
	elif score in range (17, 20):
		cleave_right(TILES.RED)
		to_reset_hazards = true
		
	
	if score % 4 == 0:
		spawn_danger_sign_on_player()
	elif ghost.active:
		place_ghost(ghost.position)
		ghost.active = false
	

# TODO: Refactor the helpers below to overlay nodes instead of setting cells


func set_floor_tile(cell_pos: Vector2, tile: Dictionary):
	floor.set_cell(cell_pos, tile.src, tile.atlas, tile.alt)

func set_hazard_tile(cell_pos: Vector2, tile: Dictionary):
	hazards.set_cell(cell_pos, tile.src, tile.atlas, tile.alt)

func place_ghost(cell_pos: Vector2):
	ghost_map.set_cell(cell_pos, TILES.GHOST.src, TILES.GHOST.atlas, TILES.GHOST.alt)

func reset_hazards():
	for cell_pos in floor.get_used_cells():
		hazards.set_cell(cell_pos, -1, Vector2(-1, -1), 0)

func cleave_left(tile: Dictionary):
	for cell_pos in floor.get_used_cells():
		if cell_pos.x <= 9:
			set_hazard_tile(cell_pos, tile)
			#hazards.set_cell(cell_pos, 2, Vector2(0, 0), 3)

func cleave_right(tile: Dictionary):
	for cell_pos in floor.get_used_cells():
		if cell_pos.x >= 10:
			set_hazard_tile(cell_pos, tile)
