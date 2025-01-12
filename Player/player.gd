extends CharacterBody2D

"""
Player movement-related functionality should exist here.
"""

@onready var walls = get_node("../TileManager/Walls")

# TODO: Signal to tell the TileManager which tile(s) to light up
signal light_up_tile(cell_pos: Vector2)

# DONE: Grid-based movement, double tap function (customize in _on_double_tap), light up tiles
const TILE_SIZE: int = 32
const PLAYER_SIZE: int = 32
const WIDTH: int = 640
const HEIGHT: int = 448

var directions = { # Directions the player can go in, and if double tapped
		"move_right": {"dir": Vector2(1, 0), "dbl": false, "timer": Timer},
		"move_left": {"dir": Vector2(-1, 0), "dbl": false, "timer": Timer},
		"move_up": {"dir": Vector2(0, -1), "dbl": false, "timer": Timer},
		"move_down": {"dir": Vector2(0, 1), "dbl": false, "timer": Timer},
}
var last_key = null
var last_tap_time = 0
var double_tap_window = 0.25
var can_light_up = false

@onready var player_sprite = $AnimatedSprite2D

var has_key = false

func _ready() -> void:
	$Hitbox.area_entered.connect(_on_hitbox_area_entered)
	GameEvents.player_died.connect(_on_player_died)

func _physics_process(delta: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	
	# Toggle lighting up tiles
	if Input.is_action_just_pressed("ui_accept"):
		if can_light_up:
			can_light_up = false
			print("Not lighting up tiles")
		else:
			can_light_up = true
			print("Lighting up tiles")
	
	handle_movement(delta)
	align_position_to_grid()

# Aligns player position to the grid
func align_position_to_grid() -> void:
	var half_size = floor(TILE_SIZE / 2)
	position.x = floor((position.x - half_size) / TILE_SIZE) * TILE_SIZE + half_size
	position.y = floor((position.y - half_size) / TILE_SIZE) * TILE_SIZE + half_size


# Handles player grid-based movement and input
func handle_movement(_delta) -> void:	
	for action in directions:		
		if Input.is_action_just_pressed(action):
			# Either double tap action or move one tile
			if not _detect_double_tap(action):
				_move_one_cell(directions[action].dir)

# Detect if the player double tapped, an call a double tap func
func _detect_double_tap(action) -> bool:
	var current_time = Time.get_ticks_msec() / 1000.0
	
	if last_key == action and (current_time - last_tap_time) <= double_tap_window:
		# double tap detected
		_on_double_tap(action)
		last_key = null # reset to prevent further detection
		return true
	else:
		last_key = action
		last_tap_time = current_time
		return false

# Dash/Slide on double key press for a given direction
func _on_double_tap(action):
	# Dash two tiles
	for I in range(0,2):
		_move_one_cell(directions[action].dir)
			
	
	# Slide as long as there is a next tile:
	#while can_move(directions[action].dir):
		#position = position + directions[action].dir * TILE_SIZE

# Check if next cell in a given direction is part of Walls 
# Moves one cell in that direction and lights up the previous tile
func _move_one_cell(direction: Vector2):
	var next_cell = Vector2i(floor(position.x / TILE_SIZE), floor(position.y / TILE_SIZE)) + Vector2i(direction)
	if not walls.get_used_cells().has(next_cell):
		_light_up_tile()
		position += direction * TILE_SIZE


# Lights up a tile on Floor at current position
func _light_up_tile():
	var cell_pos = Vector2(position.x / TILE_SIZE, position.y / TILE_SIZE)
	if can_light_up:
		light_up_tile.emit(cell_pos)


func power_up():
	print("power")
	# SPEED = 600
	
	
func pick_up_key():
	print("key acquired")
	has_key = true;


func _on_hitbox_area_entered(area: Area2D):
	print("Player took ", area.damage, " damage")
	GameState.update_life(-area.damage)
	

func _on_player_died():
	print("Player died (currently does nothing)")
	# queue_free()

func _kill():
	queue_free()
