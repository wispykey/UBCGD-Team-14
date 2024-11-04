extends Node

var last_event = 0
const TILE_LENGTH = 60
var gameOver = false

@onready var root = get_tree().root.get_node("MainScreen")

func _ready() -> void:
	root.get_node("Main").connect("gameOver", update_gameOver)

func update_gameOver(val: bool):
	gameOver = val

var player_x = 1
var player_y = 1

func setPlayer_x(num: int) -> void:
	player_x = num;
	root.player_x.emit(num)
	
func setPlayer_y(num: int) -> void:
	player_y = num;
	root.player_y.emit(num)

func _process(delta: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var x_movement := Input.get_axis("move_left","move_right")		
	var y_movement := Input.get_axis("move_up","move_down")
	
	if last_event != 0:
		var time = Time.get_ticks_msec()
		var interval = time -last_event
		if interval < 200:
			return
		else:
			last_event = 0;

	if gameOver:
		return

	if x_movement > 0 && ((player_x - 1) * TILE_LENGTH) < (6 * TILE_LENGTH):
		last_event = Time.get_ticks_msec()
		self.position.x = self.position.x + TILE_LENGTH
		setPlayer_x(player_x + 1)
	elif x_movement < 0 && ((player_x - 1) * TILE_LENGTH) > 0:
		last_event = Time.get_ticks_msec()
		self.position.x = + self.position.x - TILE_LENGTH
		setPlayer_x(player_x - 1)
	elif y_movement > 0 && ((player_y - 1) * TILE_LENGTH) < (6 * TILE_LENGTH):
		last_event = Time.get_ticks_msec()
		self.position.y = self.position.y + TILE_LENGTH
		setPlayer_y(player_y + 1)
	elif y_movement < 0 && ((player_y - 1) * TILE_LENGTH) > 0:
		last_event = Time.get_ticks_msec()
		self.position.y = self.position.y - TILE_LENGTH
		setPlayer_y(player_y - 1)
