extends Node
# Andrew Mainella
# 31 October 2024
# This script is to be attached to the ColorRect of the Tile component

var color_def_instance = color_def.new()
var rng = RandomNumberGenerator.new()
var current_number = rng.randi_range(0, 6)
var last_call = 0
var row = 1 # one based indexing lol
var column = 1 # one based indexing lol
var player_x = 1
var player_y = 1
var gameOver = false

@onready var root = self.get_tree().root.get_node("MainScreen")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.color = color_def_instance.getColor(current_number)
	row = self.get_parent().get_meta("Row")
	column = self.get_parent().get_meta("Column")
	root.get_node("Main").connect("player_x", update_x)
	root.get_node("Main").connect("player_y", update_y)
	root.get_node("Main").connect("gameOver", update_gameOver)
	if row == null || column == null:
		# This is not good something very wrong.
		print("Something wrong")
	# This is obiously a stuid solution below
	if row == 1 && column == 1 && current_number == 0:
		#The top left tile the play spawns on is red remove it
		current_number = rng.randi_range(0, 6)
		_ready()

func update_x(num: int) -> void:
	player_x = num
	
	
func update_y(num: int) -> void:
	player_y = num

func update_gameOver(val: bool) -> void:
	gameOver = val

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if current_number == 0 && row == self.player_y && column == self.player_x && self.gameOver == false:
		# The tile is red with player on it
		print("Row " + str(row) + "\nColumn " + str(column) + "\ncurrent_number " + str(current_number) + "\nPlayer X: " + str(self.player_x) + "\nPlayer Y: " + str(self.player_y))
		var game_over_resource = load("res://Prototyping/Andrew_Mainella/GameOver.tscn")
		var game_over = game_over_resource.instantiate()
		root.get_node("Main").add_child(game_over)
		self.gameOver = true
		root.gameOver.emit(true)
		return
	
	var time = Time.get_ticks_msec()
	
	if (last_call - time) < 1 && not gameOver:
		last_call = time + 500
		current_number = color_def_instance.getNextColor(current_number)
		self.color = color_def_instance.getColor(current_number)
		return
	return
