extends Node

@onready var main =  get_tree().root.get_node("MainScreen")

func _on_pressed() -> void:
	var new_scene = load("res://Prototyping/Andrew_Mainella/Home_Screen.tscn")
	main.get_node("Main").queue_free()
	main.add_child(new_scene.instantiate())
