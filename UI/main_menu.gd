extends Control

const nextScene = preload("res://UI/level_selection.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$VBoxContainer/start_button.grab_focus()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

		
func _on_start_button_pressed() -> void:
	#print("start pressed!!")
	#$TransitionScreen.show()
	#$TransitionScreen.transition()
	TransitionScreen.transition()
	await TransitionScreen.on_transition_finished
	get_tree().change_scene_to_file("res://UI/level_selection.tscn")


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_transition_screen_transitioned() -> void:
	get_tree().change_scene_to_file("res://UI/level_selection.tscn")
	#pass # Replace with function body.
