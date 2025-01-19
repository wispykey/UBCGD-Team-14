extends CharacterBody2D

"""
Player movement-related functionality should exist here.
"""

# TODO: Maybe remove walls variable coupling, low priority
# Can't make it a const because it's @onready
@onready var walls: TileMapLayer = get_node("../TileManager/Walls")

signal light_up_tile(cell_pos: Vector2) # Signal for tileManager to modify itself

# TODO: Use TileManager variables; if TileManager is global
const TILE_SIZE: int = 32
const WIDTH: int = 640
const HEIGHT: int = 448

## Player propertes
const PLAYER_SIZE: int = 32
@onready var player_sprite: AnimatedSprite2D = $AnimatedSprite2D
var has_key: bool = false
var can_light_up: bool = false

var directions: Dictionary = { # Directions the player can go in
		"move_right": {"dir": Vector2(1, 0), "held": false, "count": 0, "timer": Timer},
		"move_left": {"dir": Vector2(-1, 0), "held": false, "count": 0, "timer": Timer},
		"move_up": {"dir": Vector2(0, -1), "held": false, "count": 0, "timer": Timer},
		"move_down": {"dir": Vector2(0, 1), "held": false, "count": 0, "timer": Timer},
}

# Player Visual Modifications to AnimatedSprite2D
const original_modulate: Color = Color(1, 1, 1)  # White (default color)
const max_color: Color = Color(0, 0, 1) # Blue. TODO: choose a better color to change to

## COMMENTED OUT: "On-beat" validation variables
#var current_time = 0.0 # Time in seconds of current beat
#var last_beat_time = 0.0 # Time of last beat
#const VALID_BEAT_WINDOW = 0.15 # Buffer for valid/onbeat input
#const DELAY_TIME = 0.15 # human reaction time

## COMMENTED OUT: Double tap variables
#var last_key = null
#var last_tap_time = 0
#var double_tap_window = 0.25


func _ready() -> void:
	$Hitbox.area_entered.connect(_on_hitbox_area_entered)
	GameEvents.player_died.connect(_on_player_died)
	Conductor.quarter_beat.connect(_on_quarter_beat)

# Get the input direction and handle the movement/deceleration.
func _physics_process(delta: float) -> void:
	# Toggle lighting up tiles
	if Input.is_action_just_pressed("ui_accept"):
		if can_light_up:
			can_light_up = false
			print("Not lighting up tiles")
		else:
			can_light_up = true
			print("Lighting up tiles")
	
	# Timing code
	#current_time += delta
	
	handle_movement(delta)
	align_position_to_grid()


# Handles player grid-based movement and input
func handle_movement(_delta) -> void:	
	for action in directions:
		if Input.is_action_just_pressed(action):
			_move_one_cell(directions[action].dir)
			directions[action].held = true
			
			## COMMENTED OUT: Double Tap code
			# Either double tap action or move one tile
			#if not _detect_double_tap(action):
				#_move_one_cell(directions[action].dir)
		elif Input.is_action_just_released(action):
			directions[action].held = false
			handle_sustain(action, directions[action].count)


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
func handle_sustain(action, count):
	if count > 2:
		move_to_end(directions[action].dir)
	else:
		move_amount(directions[action].dir, count)
	update_color(0)
	# TODO: when pressing multiple keys, visual color not aligned upon releasing one

# Moves player by given count and direction
# Lights up tiles
func move_amount(dirction: Vector2, count):
	for I in range(0, count*2):
			_move_one_cell(dirction)

# Moves player by given direction until hitting a wall
# Does not light up tiles
func move_to_end(direction: Vector2):
	while _is_valid_next_cell(direction):
		#_light_up_tile()
		position = position + direction * TILE_SIZE


### VISUAL EFFECTS CODE
# Function to update the player's color based on beats held
func update_color(beats_held: int):
	# Blend from original_modulate to max_color
	var intensity = clamp(beats_held / 3.0, 0, 1)  # Adjust "10.0" for max beats
	player_sprite.modulate = original_modulate.lerp(max_color, intensity)


### TIMING/BEAT CODE:
# Update time of most recent beat 
func _on_quarter_beat(_beat_num):
	#last_beat_time = current_time
	
	for action in directions:
		if directions[action].held:
			directions[action].count += 1
			update_color(directions[action].count)
		else:
			directions[action].count = 0
	#print("beat")

## Check if input is within time range, early/before
#func is_input_onbeat():
	#var valid_start = last_beat_time - VALID_BEAT_WINDOW
	#var valid_end = last_beat_time + VALID_BEAT_WINDOW
	#
	#var too_early = current_time < valid_start
	#var too_late = current_time > valid_end
	#if too_early:
		#print("too early!")
	#if too_late:
		#print("too late!")
	#
	##Check if input falls in buffer range
	#return not too_early and not too_late


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
	print("Player took ", area.damage, " damage from ", area.name)
	GameState.update_life(-area.damage)
	
	if area is Projectile:
		area.queue_free()


func _on_player_died():
	print("Player died (currently does nothing)")
	# queue_free()

func _kill():
	queue_free()
