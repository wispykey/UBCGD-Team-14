extends Node

func _ready() -> void:
	$ScoreLabel.text = "Score: " + str(GameState.score)


func _on_home_button_pressed() -> void:
	print("pressed")
	get_tree().change_scene_to_file("res://UI/main_menu.tscn")


func _on_restart_button_pressed() -> void:
	# TODO reset the game
	pass # Replace with function body.
