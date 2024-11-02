extends CharacterBody2D

@onready
var tileMap = get_node("../Background")

const TILE_SIZE: int = 32
const PLAYER_SIZE: int = 32
const WIDTH: int = 640
const HEIGHT: int = 480
var tileType: int = 1
var cells_to_reset = []
var beatNum: int = 0

func _ready() -> void:
	position.x = 304
	position.y = 240
	Conductor.quarter_beat.connect(_on_quarter_beat)

func _physics_process(_delta: float) -> void:
	if Input.is_action_pressed("ui_accept"):
		tileType = 0
	else:
		tileType = 1
	
	# Get WASD or Arrow keys and move player one tile in direction
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

func colorTile() -> void:
	var cellPos = Vector2(position.x/TILE_SIZE, position.y/TILE_SIZE)
	if (tileType == 0):
		tileMap.set_cell(cellPos, 2, Vector2(0,0), 0)
		cells_to_reset.append(cellPos)
	if (tileType == 1):
		tileMap.set_cell(cellPos, 2, Vector2(2,0), 0)
		cells_to_reset.append(cellPos)
	

func _on_quarter_beat(_beat_num: int):
	if (beatNum >= 4):
		for cellPos in cells_to_reset:
			tileMap.set_cell(cellPos, 2, Vector2(0, 0), 0)
		cells_to_reset.clear()
		beatNum = 0
	beatNum += 1

func canMoveLeft() -> bool:
	return (position.x > TILE_SIZE + PLAYER_SIZE)
func canMoveRight() -> bool:
	return (position.x < WIDTH - PLAYER_SIZE - TILE_SIZE)
func canMoveUp() -> bool:
	return (position.y > TILE_SIZE + PLAYER_SIZE)
func canMoveDown() -> bool:
	return (position.y < HEIGHT - PLAYER_SIZE - TILE_SIZE)
