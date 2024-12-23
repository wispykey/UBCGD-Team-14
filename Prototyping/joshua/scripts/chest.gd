extends Area2D

@onready var chest_open_sound = $AudioStreamPlayer2D

var is_opened = false
func _on_body_entered(body: Node2D) -> void:
	if not is_opened and body.has_key:  # Check if the touching object is the player
		print("CHEST OPENED")
		chest_open_sound.play()
		is_opened = true
		body.has_key = false		
		hide()  # Remove the coin from the scene
