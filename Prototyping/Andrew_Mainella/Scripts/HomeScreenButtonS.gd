extends Node

@onready var main =  get_tree().root.get_node("MainScreen")

func _on_pressed() -> void:
	var new_scene = load("res://Prototyping/Andrew_Mainella/Game_Scene.tscn")
	main.get_node("HomeScreen").queue_free()
	main.add_child(new_scene.instantiate())
