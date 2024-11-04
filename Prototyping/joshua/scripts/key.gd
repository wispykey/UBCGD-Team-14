extends Area2D

var isCollected = false

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player" and not isCollected:  # Check if the touching object is the player
		body.pickUpKey()  # Play the touch sound
		isCollected = true
		hide()  # Remove the coin from the scene
