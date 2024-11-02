extends CharacterBody2D

# When the game is ready, get a reference to the tileMap "Background"
@onready
var tileMap = get_node("../Background")

const TILE_SIZE: int = 32
const PLAYER_SIZE: int = 32
const WIDTH: int = 640
const HEIGHT: int = 480

var tileType: int = 2
var cells_to_reset = []
var beatNum: int = 0

# Change this value to be able to color more/less tiles before resets
const maxBeats: int = 4

# runs once on startup, set position close to center 
# and run _on_quarter_beat every quarter_beat emitted from the Conductor
func _ready() -> void:
	position.x = 304
	position.y = 240
	Conductor.quarter_beat.connect(_on_quarter_beat)

#main function
func _physics_process(_delta: float) -> void:
	# if holding down spacebar, player can color blue tiles (0)
	# otherwise, colors black tiles (2) by default 
	if Input.is_action_pressed("ui_accept"):
		tileType = 0
	else:
		tileType = 2
	
	# Get WASD or Arrow keys and move player one tile in direction if player can move
	# Colors the tile the player was previously on
	if Input.is_action_just_pressed("move_right") && canMoveRight():
		colorTile()
		position.x += TILE_SIZE
	if Input.is_action_just_pressed("move_left") && canMoveLeft():
		colorTile()
		position.x -= TILE_SIZE
	if Input.is_action_just_pressed("move_up") && canMoveUp():
		colorTile()
		position.y -= TILE_SIZE
	if Input.is_action_just_pressed("move_down") && canMoveDown():
		colorTile()
		position.y += TILE_SIZE

# Colors a tile based on player's position
func colorTile() -> void:
	var cellPos = Vector2(position.x/TILE_SIZE, position.y/TILE_SIZE)
	
	# If tileType is set to Blue (0), set the cell as a blue one 
	# and add it to the list of cells to be removed
	if (tileType == 0):
		tileMap.set_cell(cellPos, 2, Vector2(tileType,0), 0)
		cells_to_reset.append(cellPos)
	# If tileType is set to Black (1), set the cell as a black one
	# and add it to the list of cells to be removed
	if (tileType == 2):
		tileMap.set_cell(cellPos, 2, Vector2(tileType,0), 0)
		cells_to_reset.append(cellPos)


# Called every beat based on the Conductor
# Every 4 beats, resets all cells in the list of cells to be removed to blue tiles
func _on_quarter_beat(_beat_num: int):
	if (beatNum >= maxBeats):
		
		# Comment out this code to never reset tiles
		#for cellPos in cells_to_reset:
			#tileMap.set_cell(cellPos, 2, Vector2(0, 0), 0)
		#cells_to_reset.clear()
		# 
		
		beatNum = 0
	beatNum += 1

# Functions that check if the player can move a tile in a given direction
func canMoveLeft() -> bool:
	return (position.x > TILE_SIZE + PLAYER_SIZE)
func canMoveRight() -> bool:
	return (position.x < WIDTH - PLAYER_SIZE - TILE_SIZE)
func canMoveUp() -> bool:
	return (position.y > TILE_SIZE + PLAYER_SIZE)
func canMoveDown() -> bool:
	return (position.y < HEIGHT - PLAYER_SIZE - TILE_SIZE)
