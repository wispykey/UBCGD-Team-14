extends Node

signal player_x(new_value)
signal player_y(new_value)
signal gameOver(new_value)

@onready var main = self.get_tree().root.get_node("MainScreen")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var player: AudioStreamPlayer2D = $AudioStreamPlayer2D
	if main.selected_song == "Seven Nation Army":
		print("Here")
		player.stream = load("res://Prototyping/Andrew_Mainella/Assets/Seven_Nation_Army_Audio.mp3")
	elif main.selected_song == "Pump It Up":
		player.stream = load("res://Prototyping/Andrew_Mainella/Assets/Pump_It_Up_Audio.mp3")
	elif main.selected_song == "Dancing Queen":
		player.stream = load("res://Prototyping/Andrew_Mainella/Assets/Dancing_Queen_Audio.mp3")
	else:
		player.stream = load("res://Prototyping/Andrew_Mainella/Assets/Do_It_Right_Audio.mp3")
	
	$AudioStreamPlayer2D.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
