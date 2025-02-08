extends Node2D

@export var lightning: PackedScene

# TODO: Parameterize
var num_waves: int = 8

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Conductor.quarter_beat.connect(spawn_lightning_strikes)

func spawn_lightning_strikes(beat_num: int):
	if num_waves <= 0:
		queue_free()
	if int(Conductor.num_beats_passed) % 6 != 0:
		return
		
	num_waves -=1
	var num_strikes = 4
	var positions = get_random_quadrant_positions()
	for i in num_strikes:
		var strike = lightning.instantiate()
		strike.position = positions[i]
		add_child(strike)
	

func get_random_quadrant_positions():
	# TODO: Spread out spawns across quadrants randomly
	return [Vector2(112, 112), 
			Vector2(496, 112), 
			Vector2(112 + 64, 336),
			Vector2(496 + 64, 336)]
