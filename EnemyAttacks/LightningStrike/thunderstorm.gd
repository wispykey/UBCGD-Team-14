extends Node2D

@export var lightning: PackedScene

var num_waves: int = 8
var num_strikes: int = 4
var beats_between_waves: int = 6

const TILE_SIZE: int = 32
const WIDTH: int = 640
const HEIGHT: int = 448
const HOR_TILES: int = WIDTH / TILE_SIZE
const VER_TILES: int = HEIGHT / TILE_SIZE

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Conductor.quarter_beat.connect(spawn_lightning_strikes)
	
func set_waves(waves: int):
	num_waves = waves
	
func set_beats_between_waves(beats: int):
	beats_between_waves = beats

func spawn_lightning_strikes(beat_num: int):
	if int(Conductor.num_beats_passed) % beats_between_waves != 0:
		return
	num_waves -=1
	if num_waves < 0:
		queue_free()
	var positions = get_random_quadrant_positions()
	for i in num_strikes:
		var strike = lightning.instantiate()
		strike.position = positions[i]
		add_child(strike)
	

func get_random_quadrant_positions():
	# TODO: Spread out spawns across quadrants randomly
	var positions = []
	for i in range(num_strikes):
		positions.append(get_random_position())
	return positions

func get_random_position() -> Vector2:
	# Create a random x and y for the danger sign
	# randi_range gets random integer within the range of tiles within the walls
	# x and y are scaled up, and add adjustment to align danger sign 
	# b/c danger sign position x,y is at its center, not its top left corner
	var random_x = randi_range(1, HOR_TILES - 2) * TILE_SIZE + TILE_SIZE/2
	var random_y = randi_range(1, VER_TILES - 2) * TILE_SIZE + TILE_SIZE/2
	
	return Vector2(random_x, random_y)
