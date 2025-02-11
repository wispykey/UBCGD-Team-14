extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var animation = $AnimationPlayer
	animation.play("title_sequence")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	#if Input.is_action_just_pressed("ui_accept"):
		#pass 
		
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		get_tree().change_scene_to_file("res://Prototyping/Joshua/Scenes/main_menu.tscn")
