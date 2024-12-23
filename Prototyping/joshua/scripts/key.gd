extends Area2D

@onready var pick_up_sound = $AudioStreamPlayer2D
var is_collected = false

func _on_body_entered(body: Node2D) -> void:
	if not is_collected:  # Check if the touching object is the player
		body.pick_up_key()  # Play the touch sound
		is_collected = true
		pick_up_sound.play()
		hide()  # Remove the coin from the scene
