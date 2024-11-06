extends Node

@onready var main =  get_tree().root.get_node("MainScreen")
@onready var homeScreen = preload("res://Prototyping/Andrew_Mainella/Home_Screen.tscn")

func _on_pressed() -> void:
	#home screen
	main.get_node("Main").queue_free() # remove game
	main.add_child(homeScreen.instantiate()) # add homescreen
