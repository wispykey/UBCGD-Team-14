extends CharacterBody2D

"""
Player movement-related functionality should exist here.
"""

# TODO: Maybe remove walls variable coupling, low priority
# Can't make it a const because it's @onready
@onready var walls: TileMapLayer = get_node("../TileManager/Walls")

signal light_up_tile(cell_pos: Vector2) # Signal for tileManager to modify itself

@export var debug_timing_info: bool = false

# TODO: Use TileManager variables; if TileManager is global
const TILE_SIZE: int = 32
const WIDTH: int = 640
const HEIGHT: int = 448

# The number of charges to activate dash-to-the-wall
const MAX_CHARGES: int = 3
# The number of tiles to move per beat of sustained input
const TILES_PER_CHARGE: int = 3
# Duration to distinguish the releases of short taps vs intentional sustained taps
const MIN_HOLD_DURATION: float = 0.35
# Allow inputs to be timed earlier/later than the beat by this amount
const LEEWAY_IN_SECS: float = 0.12 

# Allow player to shift timings to match their device/feel
const TIMING_CALIBRATION_STEP: float = 0.02 # In seconds
var calibration_offset: float = -0.00 # In seconds

## Player propertes
const PLAYER_SIZE: int = 32
@onready var player_sprite: AnimatedSprite2D = $AnimatedSprite2D
var has_key: bool = false
var can_light_up: bool = false

var directions: Dictionary = { # Directions the player can go in
		"move_right": {"dir": Vector2(1, 0), "held": 0.0},
		"move_left": {"dir": Vector2(-1, 0), "held": 0.0},
		"move_up": {"dir": Vector2(0, -1), "held": 0.0},
		"move_down": {"dir": Vector2(0, 1), "held": 0.0},
}

# Colors for each level of charge.
const CHARGE_COLORS = [
	Color(1, 1, 1), # 0-index is original modulate
	Color(1, 0.65, 0), 
	Color(1, 0.2, 0.2),
	Color(0, 0.8, 1), 
]

## COMMENTED OUT: Double tap variables
#var last_key = null
#var last_tap_time = 0
#var double_tap_window = 0.25


func _ready() -> void:
	$Hitbox.area_entered.connect(_on_hitbox_area_entered)
	GameEvents.player_died.connect(_on_player_died)
	Conductor.quarter_beat.connect(_on_quarter_beat)

# Get the input direction and handle the movement/deceleration.
func _process(delta: float) -> void:
	# Toggle lighting up tiles
	if Input.is_action_just_pressed("ui_accept"):
		if can_light_up:
			can_light_up = false
			print("Not lighting up tiles")
		else:
			can_light_up = true
			print("Lighting up tiles")
			
	if Input.is_action_just_pressed("calibrate_earlier"):
		calibration_offset -= TIMING_CALIBRATION_STEP
		print("New offset: ", calibration_offset)
	
	if Input.is_action_just_pressed("calibrate_later"):
		calibration_offset += TIMING_CALIBRATION_STEP
		print("New offset: ", calibration_offset)
	
	handle_movement(delta)
	align_position_to_grid()

# Handles player grid-based movement and input
func handle_movement(delta: float) -> void:
	# Prioritize new key presses (e.g. to allow 'cancelling' a charge)
	for action in directions:
		if Input.is_action_just_pressed(action):
			_move_one_cell(directions[action].dir)
			directions[action].held += delta
			handle_input_timing()
			return # Early returns prevent processing multiple directions
	
	for action in directions:	
		if Input.is_action_just_released(action):
			if directions[action].held > MIN_HOLD_DURATION:
				handle_input_timing()
			handle_release(action)
			return
	
	for action in directions:
		if Input.is_action_pressed(action):
			directions[action].held += delta
			update_color(directions[action].held)
			return
			
		## COMMENTED OUT: Double Tap code
		# Either double tap action or move one tile
		#if not _detect_double_tap(action):
			#_move_one_cell(directions[action].dir)


## BASIC MOVEMENT CODE:
# Aligns player position to the grid
func align_position_to_grid() -> void:
	var half_size = floor(TILE_SIZE / 2)
	position.x = floor((position.x - half_size) / TILE_SIZE) * TILE_SIZE + half_size
	position.y = floor((position.y - half_size) / TILE_SIZE) * TILE_SIZE + half_size

# Moves one cell in that direction and lights up the previous tile
func _move_one_cell(direction: Vector2):
	if _is_valid_next_cell(direction):
		_light_up_tile()
		position += direction * TILE_SIZE

# Checks if next cell in given direction is valid (ie. not a wall)
func _is_valid_next_cell(direction):
	var next_cell = Vector2i(floor(position.x / TILE_SIZE), floor(position.y / TILE_SIZE)) + Vector2i(direction)
	return not walls.get_used_cells().has(next_cell)

# Lights up a tile on Floor at current position
func _light_up_tile():
	var cell_pos = Vector2(position.x / TILE_SIZE, position.y / TILE_SIZE)
	if can_light_up:
		light_up_tile.emit(cell_pos)


### SUSTAINED INPUT CODE:
# Handle sustained inputs on release
# Eventually, could make it a match (switch case)
func handle_release(action):
	# Instead of manually counting charges on quarter beats, derive based on held duration 
	# LEEWAY_IN_SECS allows player to release slightly early and still get the next beat's powerup
	var count = floori((directions[action].held + LEEWAY_IN_SECS) / Conductor.seconds_per_quarter_note)
	if count >= MAX_CHARGES:
		move_to_end(directions[action].dir)
	else:
		move_amount(directions[action].dir, count * TILES_PER_CHARGE) 
	
	for other_action in directions:
		directions[other_action].held = 0.0
		directions[other_action].count = 0
	
	# Reset player color
	update_color(0.0)

# Moves player by given count and direction
# Lights up tiles
func move_amount(direction: Vector2, num_tiles: int):
	for i in range(num_tiles):
		_move_one_cell(direction)

# Moves player by given direction until hitting a wall
# Does not light up tiles
func move_to_end(direction: Vector2):
	while _is_valid_next_cell(direction):
		#_light_up_tile()
		position = position + direction * TILE_SIZE


### VISUAL EFFECTS CODE
# Function to update the player's color based on beats held
func update_color(duration: float):
	# Derive charges by comparing held duration to known beat duration
	var num_charges: float = duration / Conductor.seconds_per_quarter_note
	# Decimal remainder lets us cycle intensity from 0 to 0.99 between every change.
	var intensity = num_charges - floori(num_charges) if num_charges < MAX_CHARGES else 1
	# Two adjacent indices in CHARGE_COLORS
	var next = min(1+int(num_charges), MAX_CHARGES)
	var curr = next-1
	var target_color = CHARGE_COLORS[next]
	var curr_color = CHARGE_COLORS[curr]
	# < -1.0 parameter is ease-in-out
	intensity = ease(intensity, -3.0)
	player_sprite.modulate = curr_color.lerp(target_color, intensity)

var buffer_count = 0
### TIMING/BEAT CODE:
# Update time of most recent beat 
func _on_quarter_beat(_beat_num):
	pass

# Evaluate how well player timed an input (presses and long releases)
func handle_input_timing():
	# Subtract one because beats are 1-indexed
	var prev_beat_in_secs = (Conductor.num_beats_passed-1) * Conductor.seconds_per_quarter_note
	var input_time = Conductor.current_time_in_secs
	var next_beat_in_secs = prev_beat_in_secs + Conductor.seconds_per_quarter_note
	var calibrated_time = input_time + calibration_offset
	# If player hit early, "before_next" will be the anticipation before intended beat
		# and "after_prev" will be the time since previous beat
	# If player hit late, "before_next" will be the time before next beat
		# and "after_prev" will be the delay after the intended beat
	var before_next = abs(calibrated_time - next_beat_in_secs)
	var after_prev = abs(calibrated_time - prev_beat_in_secs)
	var close_enough = before_next <= LEEWAY_IN_SECS or after_prev <= LEEWAY_IN_SECS

	if close_enough:
		# TODO: Do stuff here (maybe a signal). Recover health, increase combo, etc.
		pass
	else:
		# TODO: Do stuff here (maybe a signal). Lose health, reset combo, etc.
		pass
			
	if debug_timing_info:
		var result = "Good!" if close_enough else "BAD."
		var min_error = min(after_prev, before_next) * 1000
		var closest = "after" if after_prev <= before_next else "before"
		var stats = "{before} before, {after} after".format({
			"before": "%0.2f" % before_next,
			"after": "%0.2f" % after_prev})
		print("{result} {error} ms {closest} ({stats})".format({
			"error": "%0.2f" % min_error,
			"result": result,
			"closest": closest,
			"stats": stats})) 
			

### COMMENTED OUT: DOUBLE TAP MOVEMENT CODE
# Detect if the player double tapped, an call a double tap func
#func _detect_double_tap(action) -> bool:
	#var current_time = Time.get_ticks_msec() / 1000.0
	#
	#if last_key == action and (current_time - last_tap_time) <= double_tap_window:
		## double tap detected
		#_on_double_tap(action)
		#last_key = null # reset to prevent further detection
		#return true
	#else:
		#last_key = action
		#last_tap_time = current_time
		#return false

# Dash/Slide on double key press for a given direction
#func _on_double_tap(action):
	## Dash two tiles
	#for I in range(0,2):
		#_move_one_cell(directions[action].dir)
			#
	#
	# Slide as long as there is a next tile:
	#while can_move(directions[action].dir):
		#position = position + directions[action].dir * TILE_SIZE


## COLLECTIBLES/MISC CODE:
func power_up():
	print("power")
	# SPEED = 600
	
	
func pick_up_key():
	print("key acquired")
	has_key = true;


func _on_hitbox_area_entered(area: Area2D):
	#print("Player took ", area.damage, " damage from ", area.name)
	GameState.update_life(-area.damage)
	
	if area is Projectile:
		area.queue_free()


func _on_player_died():
	print("Player died (currently does nothing)")
	# queue_free()

func _kill():
	queue_free()
