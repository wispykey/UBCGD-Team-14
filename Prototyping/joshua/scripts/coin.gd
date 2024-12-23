extends Area2D

@onready var pickup = $AudioStreamPlayer2D

var is_collected = false

func _on_body_entered(body: Node2D) -> void:
	if not is_collected:  # Check if the touching object is the player
		print("+1 coin")		
		pickup.play()  # Play the touch sound
		is_collected = true
		hide()  # Remove the coin from the scene
