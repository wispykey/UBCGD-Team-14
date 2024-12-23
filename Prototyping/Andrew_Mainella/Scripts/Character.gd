extends CharacterBody2D

var last_event = 0
const TILE_LENGTH = 60
var gameOver = false

@onready var root = get_tree().root.get_node("MainScreen")

func _ready() -> void:
	root.get_node("Main").connect("gameOver", update_gameOver)

func update_gameOver(val: bool):
	gameOver = val
	if val == true:
		var character: AnimatedSprite2D = self.get_node("AnimatedSprite2D")
		character.animation = "dead"

var player_x = 1
var player_y = 1

func setPlayer_x(num: int) -> void:
	player_x = num;
	root.get_node("Main").player_x.emit(num)
	
func setPlayer_y(num: int) -> void:
	player_y = num;
	root.get_node("Main").player_y.emit(num)

func setPlayerXPosition(newPos: int, y: int) -> void:
	var character: AnimatedSprite2D = self.get_node("AnimatedSprite2D")
	character.animation = "walk_left"
	await get_tree().create_timer(0.05).timeout
	var tween = create_tween()
	tween.tween_property(self, 'position', Vector2(newPos, y), 0.1)
	await get_tree().create_timer(0.2).timeout
	if self.gameOver == false:
		character.animation = "dance"
	
func setPlayerYPosition(newPos: int, x: int) -> void:	
	var character: AnimatedSprite2D = self.get_node("AnimatedSprite2D")
	character.animation = "walk_left"
	await get_tree().create_timer(0.05).timeout
	var tween = create_tween()
	tween.tween_property(self, 'position', Vector2(x, newPos), 0.1)
	await get_tree().create_timer(0.2).timeout
	if self.gameOver == false:
		character.animation = "dance"

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
		setPlayerXPosition(self.position.x + TILE_LENGTH, self.position.y)
		setPlayer_x(player_x + 1)
	elif x_movement < 0 && ((player_x - 1) * TILE_LENGTH) > 0:
		last_event = Time.get_ticks_msec()
		setPlayerXPosition(self.position.x - TILE_LENGTH, self.position.y)
		setPlayer_x(player_x - 1)
	elif y_movement > 0 && ((player_y - 1) * TILE_LENGTH) < (6 * TILE_LENGTH):
		last_event = Time.get_ticks_msec()
		setPlayerYPosition(self.position.y + TILE_LENGTH, self.position.x)
		setPlayer_y(player_y + 1)
	elif y_movement < 0 && ((player_y - 1) * TILE_LENGTH) > 0:
		last_event = Time.get_ticks_msec()
		setPlayerYPosition(self.position.y - TILE_LENGTH, self.position.x)
		setPlayer_y(player_y - 1)
