extends Node


func _on_pressed() -> void:
	self.get_tree().root.get_node("Main").gameOver.emit(false)
	var root = get_tree().change_scene_to_file("res://Prototyping/Andrew_Mainella/Home_Screen.tscn")
	pass # Replace with function body.
