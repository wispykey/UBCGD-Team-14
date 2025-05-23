extends CharacterBody2D

"""
Player movement-related functionality should exist here.
"""

# TODO: Maybe remove walls variable coupling, low priority
# Can't make it a const because it's @onready
@onready var walls: TileMapLayer = get_node("../TileManager/Walls")

signal light_up_tile(cell_pos: Vector2) # Signal for tileManager to modify itself
signal spawn_afterimage(player_pos: Vector2) # SIgnal for Scene Parent to spawn afterimage
signal update_telegraph(player_pos: Vector2, charges: float, direction: Vector2) # Signal for Scene Parent to generate telegraph square
signal death_animation_finished

@export var debug_timing_info: bool = false

# TODO: Use TileManager variables; if TileManager is global
const TILE_SIZE: int = 32
const WIDTH: int = 640
const HEIGHT: int = 448

# Consecutive inputs must occur no sooner than this many beats apart
const INPUT_SPAM_INTOLERANCE: float = 0.50
# Inputs must be this many beats apart at maximum
const INPUT_ACTIVITY_REQUIREMENT: float = 1.25
# The number of charges to activate dash-to-the-wall
const MAX_CHARGES: int = 3
# The number of tiles to move per beat of sustained input
const TILES_PER_CHARGE: int = 3
# Duration to distinguish the releases of short taps vs intentional sustained taps
const MIN_HOLD_DURATION_TO_DETECT_DASH: float = 0.25
const MIN_HOLD_DURATION_TO_DISPLAY_DASH_BAR: float = 0.30
const MIN_HOLD_DURATION_TO_UPDATE_ANIM: float = 0.22
# Allow inputs to be timed earlier/later than the beat by this amount
const LEEWAY_IN_SECS: float = 0.30
# Allow releasing a held input slightly earlier to achieve next charge tier
const CHARGE_LEEWAY_IN_SECS: float = 0.15
# The amount of HP recovered per well-timed input
const HP_RECOVERY_PER_TICK: float = 0.1
# Prevent combo-pulse animation from double-triggering on first press of a held input
const COMBO_PULSE_DELAY: float = 0.30

# Allow player to shift timings to match their device/feel
const TIMING_CALIBRATION_STEP: float = 0.02 # In seconds
var calibration_offset: float = -0.00 # In seconds

## Player propertes
const PLAYER_SIZE: int = 32
@onready var player_sprite: AnimatedSprite2D = $Sprite
var has_key: bool = false
var can_light_up: bool = false
var last_action: String = "move_down"
@export var invincible: bool = false # Debug

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

var gameRunning = false

## COMMENTED OUT: Double tap variables
#var last_key = null
#var last_tap_time = 0
#var double_tap_window = 0.25


func _ready() -> void:
	$Hitbox.area_entered.connect(_on_hitbox_area_entered)
	GameEvents.player_died.connect(_on_player_died)
	GameEvents.game_start.connect(_on_game_start)
	$Pacemaker/AnimationPlayer.animation_finished.connect(_on_pacemaker_animation_finished)
	Conductor.quarter_beat.connect(_on_quarter_beat)

# Get the input direction and handle the movement/deceleration.
func _process(delta: float) -> void:
	var shader_time = $Pacemaker.material.get("shader_parameter/time")
	$Pacemaker.material.set("shader_parameter/time", shader_time + 5.0*delta)
	
	if !gameRunning:
		return
	# Toggle lighting up tiles
	#if Input.is_action_just_pressed("ui_accept"):
		#if can_light_up:
			#can_light_up = false
			#print("Not lighting up tiles")
		#else:
			#can_light_up = true
			#print("Lighting up tiles")
			
	if Input.is_action_just_pressed("calibrate_earlier"):
		calibration_offset -= TIMING_CALIBRATION_STEP
		print("New offset: ", calibration_offset)
	
	if Input.is_action_just_pressed("calibrate_later"):
		calibration_offset += TIMING_CALIBRATION_STEP
		print("New offset: ", calibration_offset)
	
	last_action = handle_movement(delta)
	update_facing()
	align_position_to_grid()
	
	# Reset combo if player has not been active enough
	if $ComboTimer.is_stopped():
		GameState.update_combo(-1)

# Handles player grid-based movement and input
func handle_movement(delta: float) -> String:
	# Prioritize new key presses (e.g. to allow 'cancelling' a charge)
	for action in directions:
		if Input.is_action_just_pressed(action):
			_move_one_cell(directions[action].dir)
			directions[action].held += delta
			handle_input_timing(1, 0.0)
			return action # Early returns prevent processing multiple directions
	
	for action in directions:	
		if Input.is_action_just_released(action):
			var duration = directions[action].held
			if duration > MIN_HOLD_DURATION_TO_DETECT_DASH:
				var combo_gain = calculate_charge_count(duration)
				handle_input_timing(combo_gain, duration)
			handle_release(action)
			return action
	
	for action in directions:
		if Input.is_action_pressed(action):
			directions[action].held += delta
			update_color(directions[action].held)
			update_dash_telegraph(directions[action].held, directions[action].dir)
			start_input_timers()
			return action
	
		## COMMENTED OUT: Double Tap code
		# Either double tap action or move one tile
		#if not _detect_double_tap(action):
			#_move_one_cell(directions[action].dir)
			
	return last_action # No input was detected this frame

func start_input_timers():
	$ComboTimer.start(Conductor.seconds_per_quarter_note * INPUT_ACTIVITY_REQUIREMENT)
	$SpamTimer.start(Conductor.seconds_per_quarter_note * INPUT_SPAM_INTOLERANCE)

func update_facing():
	var facing = last_action.split("_")[1]
	# NOTE: Only works due to coupled naming between inputs and animations
	if directions[last_action].held > MIN_HOLD_DURATION_TO_UPDATE_ANIM:
		# Set sprite to pre-dash
		var prefix = "pre_dash_"
		player_sprite.play(prefix + facing)
	else:
		player_sprite.play(facing) 
	
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

func _spawn_afterimage():
	spawn_afterimage.emit(position)

func calculate_charge_count(duration: float):
	var charge_count = floori((duration + CHARGE_LEEWAY_IN_SECS) / Conductor.seconds_per_quarter_note)
	charge_count = min(charge_count, MAX_CHARGES)
	return charge_count
	

### SUSTAINED INPUT CODE:
# Handle sustained inputs on release
# Eventually, could make it a match (switch case)
func handle_release(action):
	# Instead of manually counting charges on quarter beats, derive based on held duration 
	# LEEWAY_IN_SECS allows player to release slightly early and still get the next beat's powerup
	var charge_count = calculate_charge_count(directions[action].held)
	
	if charge_count >= MAX_CHARGES:
		move_to_end(directions[action].dir)
	else:
		move_amount(directions[action].dir, charge_count * TILES_PER_CHARGE)
		
	if charge_count > 0:
		SFX.play_dash_release(min(charge_count, MAX_CHARGES)) 
	
	for other_action in directions:
		directions[other_action].held = 0.0
	
	# Reset player color
	update_color(0.0)
	update_dash_telegraph(0, Vector2(0,0))
	
	for bar in $DashBar.get_children():
		bar.value = 0.0

# Moves player by given count and direction
# Lights up tiles
func move_amount(direction: Vector2, num_tiles: int):
	for i in range(num_tiles):
		_spawn_afterimage()
		_move_one_cell(direction)

# Moves player by given direction until hitting a wall
# Does not light up tiles
func move_to_end(direction: Vector2):
	while _is_valid_next_cell(direction):
		#_light_up_tile()
		_spawn_afterimage()
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

	var sprite_intensity = ease(intensity, -3.0)
	player_sprite.modulate = curr_color.lerp(target_color, sprite_intensity)
 
	var dash_bar 
	if num_charges > 2:
		dash_bar = $DashBar/Charge3
	elif num_charges > 1:
		dash_bar = $DashBar/Charge2
	else:
		dash_bar = $DashBar/Charge1
			
	if duration >= MIN_HOLD_DURATION_TO_DISPLAY_DASH_BAR/2.5 or dash_bar.value > 0.0:
		var bar_intensity = ease(intensity, 0.82)
		dash_bar.tint_progress = target_color
		dash_bar.value = bar_intensity

var buffer_count = 0

# Function to update player's dash telegraph based on beats held
func update_dash_telegraph(duration: float, direction: Vector2):
	var num_charges: float = duration / Conductor.seconds_per_quarter_note
	update_telegraph.emit(position, num_charges, direction)


# Evaluate how well player timed an input (presses and long releases)
func handle_input_timing(combo_gain: int, held_duration: float):
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

	# Reset combo and do not restore health if player maliciously spams inputs
	if $SpamTimer.time_left > 0 and held_duration <= 0.001:
		print("Player spam - reset combo", $SpamTimer.time_left)
		GameState.update_combo(-1)
	elif close_enough:
		GameState.update_life(HP_RECOVERY_PER_TICK) # Recover HP when inputs are timed well
		GameState.update_combo(combo_gain)
		$Pacemaker/AnimationPlayer.play("combo_success")
		SFX.play_heartbeat()
	else:
		print("Bad timing - reset combo")
		GameState.update_combo(-1)
		
	var combo_reset_time = Conductor.seconds_per_quarter_note * INPUT_ACTIVITY_REQUIREMENT
	var spam_reset_time = Conductor.seconds_per_quarter_note * INPUT_SPAM_INTOLERANCE
	
	if before_next < after_prev:
		combo_reset_time += abs(before_next)
	
	$ComboTimer.start(Conductor.seconds_per_quarter_note * INPUT_ACTIVITY_REQUIREMENT)
	$SpamTimer.start(Conductor.seconds_per_quarter_note * INPUT_SPAM_INTOLERANCE)
			
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
	if area is Projectile or area is SpinningContinuousProjectile:
		area.queue_free()
	if invincible:	
		return
	GameState.update_life(-area.damage)
	# Reset combo on taking damage (design decision)
	GameState.update_combo(-1)

func _on_game_start():
	gameRunning = true

func _on_player_died():
	gameRunning = false
	$DashBar.queue_free()
	$Sprite.queue_free()
	$Pacemaker/AnimationPlayer.speed_scale = 1.0
	$Pacemaker/AnimationPlayer.play("float_upwards")
	
func _on_pacemaker_animation_finished(anim_name):
	if anim_name == "float_upwards":
		queue_free()
		death_animation_finished.emit()

func _kill():
	queue_free()

func _on_quarter_beat(beat: int):
	if directions[last_action].held > COMBO_PULSE_DELAY:
		$Pacemaker/AnimationPlayer.play("combo_success")
		SFX.play_heartbeat()
