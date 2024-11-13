extends CharacterBody2D

# When the game is ready, get a reference to the tileMap "Background"
@onready
var tile_map = get_node("../Background")


const TILE_SIZE: int = 32
const PLAYER_SIZE: int = 32
const WIDTH: int = 640
const HEIGHT: int = 480

const BLUE_TILE = Vector2i(0,0)
const WALL_TILE = Vector2i(1,0)
const BLACK_TILE = Vector2i(2,0)

const L_SHAPE = [Vector2i(0, 0), 
				 Vector2i(0, 1), Vector2i(1, 0), Vector2i(2, 0)]

var player_pos: Vector2i = Vector2i(8, 7);
var tileType = BLUE_TILE
var cells_to_reset = []
var beatNum: int = 0
var score: int = 0

# Change this value to be able to color more/less tiles before resets
const maxBeats: int = 20

# runs once on startup, set position close to center 
# and run _on_quarter_beat every quarter_beat emitted from the Conductor
func _ready() -> void:
	position = player_pos * TILE_SIZE - Vector2i(TILE_SIZE / 2, TILE_SIZE / 2)
	Conductor.quarter_beat.connect(_on_quarter_beat)

func align_position_to_grid() -> void:
	position.x = round((position.x - TILE_SIZE / 2) / TILE_SIZE) * TILE_SIZE + TILE_SIZE / 2
	position.y = round((position.y - TILE_SIZE / 2) / TILE_SIZE) * TILE_SIZE + TILE_SIZE / 2

#main function
func _physics_process(_delta: float) -> void:
	# if holding down spacebar, player can color blue tiles (0)
	# otherwise, colors black tiles (2) by default 
	if Input.is_action_pressed("ui_accept"):
		tileType = BLACK_TILE
	else:
		tileType = BLUE_TILE
	
	handle_movement()
	align_position_to_grid()


## MOVEMENT CODE
# Move player one tile in direction if player can move
# Colors tile player was previously on and Updates nearby tiles
func handle_movement() -> void:
	var current_cell = Vector2(position.x / TILE_SIZE, position.y / TILE_SIZE)
	var directions = {
		"move_right": Vector2(1, 0),
		"move_left": Vector2(-1, 0),
		"move_up": Vector2(0, -1),
		"move_down": Vector2(0, 1),
	}
	
	for action in directions:
		if Input.is_action_just_pressed(action) and can_move(directions[action]):
			color_tile(current_cell)
			update_nearby_cells(current_cell)
			position += directions[action] * TILE_SIZE
			break #move one direction per frame


# check if the player can move a tile in a given direction
func can_move(direction: Vector2):
	var next_cell = Vector2(position.x / TILE_SIZE, position.y / TILE_SIZE) + direction
	var next_cell_type = tile_map.get_cell_atlas_coords(next_cell)
	
	if next_cell_type == WALL_TILE:
		return false
		
	var new_pos = position + direction * TILE_SIZE
	return (
		new_pos.x > PLAYER_SIZE and
		new_pos.x < WIDTH - PLAYER_SIZE and 
		new_pos.y > PLAYER_SIZE and
		new_pos.y < HEIGHT - PLAYER_SIZE
	)


# Updates the surrounding cells recursively, using an accumulator set visited_cells
func update_nearby_cells(cell, visited_cells = {}):
	if cell in visited_cells:
		return
	visited_cells[cell] = true
	
	for sc in tile_map.get_surrounding_cells(cell):
		var type = tile_map.get_cell_atlas_coords(sc)
		
		# If a tile is surrounded and black, fill it in and add it to list of tiles to clear
		# Otherwise if it is a wall, recursively check
		if is_cell_surrounded(sc):
			if type == BLACK_TILE:
				tile_map.set_cell(sc, 2, BLUE_TILE, 0)
				cells_to_reset.append(sc)
			elif type == WALL_TILE:
				tile_map.set_cell(sc, 2, WALL_TILE, 1)
				update_nearby_cells(sc, visited_cells) # recurse
	


func is_cell_surrounded(cell):
	for c in tile_map.get_surrounding_cells(cell):
		var cell_type = tile_map.get_cell_atlas_coords(c)
		if cell_type != BLUE_TILE and cell_type != WALL_TILE:
			return false
	return true


# Colors a tile based on player's position
func color_tile(cell_pos) -> void:
	# If tileType is set to Blue (0)
	if (tileType == BLUE_TILE): 
		tile_map.set_cell(cell_pos, 2, BLUE_TILE, 0)
		cells_to_reset.append(cell_pos)
	
	# If tileType is set to Black (2), set the cell as a black one
	if (tileType == BLACK_TILE):
		tile_map.set_cell(cell_pos, 2, BLACK_TILE, 0)
		cells_to_reset.append(cell_pos)
	
	score += 1
	get_node("../HUD").update_score(score)


## BEAT CODE
# Called every beat based on the Conductor
# Every 4 beats, resets all cells in the list of cells to be removed to blue tiles
func _on_quarter_beat(_beat_num: int):
	if (beatNum >= maxBeats):
		
		var temp_cells = Array(cells_to_reset)
		# Comment out this code to never reset tiles
		for cellPos in temp_cells:
			tile_map.set_cell(cellPos, 2, Vector2(2, 0), 0)
		cells_to_reset.clear()
		
		beatNum = 0
	beatNum += 1
