extends CharacterBody2D

# When the game is ready, get a reference to the tileMap "Background"
@onready
var tile_map = get_node("../Floor")
@onready
var hud = get_node("../HUD")

const TILE_SIZE: int = 32
const PLAYER_SIZE: int = 32
const WIDTH: int = 640
const HEIGHT: int = 480
const DEFIB: int = 80

const BLUE_TILE = Vector2i(0,0)
const WALL_TILE = Vector2i(1,0)
const BLACK_TILE = Vector2i(2,0)

# Set to -1 if no alternatives are valid
const VALID_TILES = {
	BLUE_TILE: {"alt": 0},
	WALL_TILE: {"alt": 1},
	BLACK_TILE: {"alt": -1},
}

const L_SHAPE = [Vector2i(0, 0), 
				 Vector2i(0, 1), Vector2i(1, 0), Vector2i(2, 0)]
				
var directions = {
		"move_right": {"dir": Vector2(1, 0), "dbl": false},
		"move_left": {"dir": Vector2(-1, 0), "dbl": false},
		"move_up": {"dir": Vector2(0, -1), "dbl": false},
		"move_down": {"dir": Vector2(0, 1), "dbl": false},
	}

var player_pos: Vector2i = Vector2i(8, 7);
var tileType = BLUE_TILE
var can_backtrack = true

var score: int = 0
var life: int = 10
var loop: int = 0

var beatNum: int = 0
# Change this value to be able to color more/less tiles before resets
var max_beats: int = 4
var enable_beat_reset: bool = true
var cells_to_reset = []

var double_tap = false
var double_move = false

# runs once on startup, set position close to center 
# and run _on_quarter_beat every quarter_beat emitted from the Conductor
func _ready() -> void:
	position = player_pos * TILE_SIZE - Vector2i(TILE_SIZE / 2, TILE_SIZE / 2)
	Conductor.quarter_beat.connect(_on_quarter_beat)

func align_position_to_grid() -> void:
	position.x = round((position.x - TILE_SIZE / 2) / TILE_SIZE) * TILE_SIZE + TILE_SIZE / 2
	position.y = round((position.y - TILE_SIZE / 2) / TILE_SIZE) * TILE_SIZE + TILE_SIZE / 2

# main function
func _physics_process(_delta: float) -> void:
	# if holding down spacebar, player can color blue tiles (0)
	# otherwise, colors black tiles (2) by default 
	if Input.is_action_pressed("ui_accept"):
		tileType = BLACK_TILE
	else:
		tileType = BLUE_TILE	
	
	#hud.update_score(score)
	#hud.update_life(life)
	
	handle_movement()
	align_position_to_grid()


## MOVEMENT CODE
# Move player one tile in direction if player can move
# Colors tile player was previously on and Updates nearby tiles
func handle_movement() -> void:
	var current_cell = Vector2(position.x / TILE_SIZE, position.y / TILE_SIZE)
	
	for action in directions:		
		if Input.is_action_just_pressed(action) and can_move(directions[action].dir):
			if directions[action].dbl:
				while can_move(directions[action].dir) and directions[action].dbl:
					color_tile(current_cell)
					spawn_afterimage(current_cell)
					position += directions[action].dir * TILE_SIZE
					current_cell = Vector2(position.x / TILE_SIZE, position.y / TILE_SIZE)
			else:
				color_tile(current_cell)
				spawn_afterimage(current_cell)
				position += directions[action].dir * TILE_SIZE
			
			life += 1
			scan_map()
			
			break # move one direction per frame
		
		if Input.is_action_just_released(action):
			directions[action].dbl = true
			if $Timer.is_stopped():
				$Timer.start()


func spawn_afterimage(cell_pos):
	var player_sprite = load("res://Prototyping/Marcus/Scenes/PrototypesV1/Afterimage.tscn")
	
	var afterimage = player_sprite.instantiate()
	afterimage.position = cell_pos * TILE_SIZE
	
	get_parent().add_child(afterimage)
	


# check if the player can move a tile in a given direction
func can_move(direction: Vector2):
	var next_cell = Vector2(position.x / TILE_SIZE, position.y / TILE_SIZE) + direction
	var next_cell_type = tile_map.get_cell_atlas_coords(next_cell)
	
	if next_cell_type == WALL_TILE:
		return false
	
	if not can_backtrack:
		if next_cell_type == BLUE_TILE:
			return false
	
	var new_pos = position + direction * TILE_SIZE
	
	return (
		new_pos.x > PLAYER_SIZE and
		new_pos.x < WIDTH - PLAYER_SIZE and 
		new_pos.y > PLAYER_SIZE and
		new_pos.y < HEIGHT - PLAYER_SIZE
	)



# Colors a tile based on player's position
func color_tile(cell_pos) -> void:
	# If tileType is set to Blue (0)
	if (tileType == BLUE_TILE): 
		tile_map.set_cell(cell_pos, 2, BLUE_TILE, 0)
	
	# If tileType is set to Black (2), set the cell as a black one
	if (tileType == BLACK_TILE):
		tile_map.set_cell(cell_pos, 2, BLACK_TILE, 0)
	
	if enable_beat_reset:
		cells_to_reset.append(cell_pos)


# Scans the map to update the score, called on movement
func scan_map():
	var num_blue_wall_tiles = 0
	
	for cell_pos in tile_map.get_used_cells():
		update_blue_wall(cell_pos)
		
		var type = tile_map.get_cell_atlas_coords(cell_pos)
		var alt = tile_map.get_cell_alternative_tile(cell_pos)
		
		if type == WALL_TILE and alt == 1:
			num_blue_wall_tiles += 1
	
	score = num_blue_wall_tiles
	
	if is_map_filled():
		print("You Won!")


func update_blue_wall(cell_pos):
	var type = tile_map.get_cell_atlas_coords(cell_pos)
		
		# If a tile is surrounded by blue tiles
		# If black, color it blue
		# If a wall, change it to a blue wall
	if is_cell_surrounded(cell_pos):
		if type == BLACK_TILE:
			tile_map.set_cell(cell_pos, 2, BLUE_TILE, 0)
			
			if enable_beat_reset:
				cells_to_reset.append(cell_pos)
			
		elif type == WALL_TILE:
			tile_map.set_cell(cell_pos, 2, WALL_TILE, 1)


func is_cell_surrounded(cell):
	for c in tile_map.get_surrounding_cells(cell):
		var cell_type = tile_map.get_cell_atlas_coords(c)
		if cell_type != BLUE_TILE and cell_type != WALL_TILE:
			return false
	return true


# Checks if the map is colored with valid tiles
func is_map_filled():
	for cellPos in tile_map.get_used_cells():
		if not is_in_valid_tiles(cellPos):
			return false
	return true


# Checks if tile at given tile position has a valid alternative tile
func is_in_valid_tiles(cellPos):
	var type = tile_map.get_cell_atlas_coords(cellPos)
	var alt = tile_map.get_cell_alternative_tile(cellPos)
	
	if alt == VALID_TILES[type].alt:
		return true
	
	return false

## BEAT CODE
# Called every beat based on the Conductor
# Every 4 beats, resets all cells in the list of cells to be removed to blue tiles
func _on_quarter_beat(_beat_num: int):
	life -= 1
	
	if life < 0:
		print("IM DEAD")
	
	if enable_beat_reset:
		if (beatNum >= max_beats):
			var temp_cells = Array(cells_to_reset)
			# Comment out this code to never reset tiles
			for cellPos in temp_cells:
				tile_map.set_cell(cellPos, 2, Vector2(2, 0), 0)
			cells_to_reset.clear()
			
			beatNum = 0
		beatNum += 1


func _on_timer_timeout() -> void:
	for action in directions:
		directions[action].dbl = false
 # Replace with function body.