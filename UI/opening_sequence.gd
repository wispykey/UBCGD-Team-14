extends Node2D

@onready var continue_label = $continue_label
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var animation = $AnimationPlayer
	continue_label.hide()
	animation.play("title_sequence")
	#$AnimationPlayer.animation_finished.connect(_on_animation_player_animation_finished)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	#if Input.is_action_just_pressed("ui_accept"):
		#pass 
		
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		get_tree().change_scene_to_file("res://UI/main_menu.tscn")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	continue_label.show()
	#var label_animation = $ContinueText
	#label_animation.play("continue_text")
