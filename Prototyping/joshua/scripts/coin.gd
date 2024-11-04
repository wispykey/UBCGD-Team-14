extends Area2D

@onready var pickup = $AudioStreamPlayer2D

var isCollected = false

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player" and not isCollected:  # Check if the touching object is the player
		print("+1 coin")		
		pickup.play()  # Play the touch sound
		isCollected = true
		hide()  # Remove the coin from the scene
