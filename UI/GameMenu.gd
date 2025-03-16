extends Node

func _ready() -> void:
	$ScoreLabel.text = "Score: " + str(GameState.score)

func _on_home_button_pressed() -> void:
	print("pressed")
	get_tree().change_scene_to_file("res://UI/main_menu.tscn")


func _on_restart_button_pressed() -> void:
	var path: String = get_parent().get_path();
	if path.ends_with("Fantasy"):
		get_tree().change_scene_to_file("res://Levels/Fantasy.tscn")
	elif path.ends_with("Supernatural"):
		get_tree().change_scene_to_file("res://Levels/Supernatural.tscn")
	else:
		get_tree().change_scene_to_file("res://UI/main_menu.tscn")
