extends Area2D

var isOpened = false
func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player" and not isOpened and body.hasKey:  # Check if the touching object is the player
		print("CHEST OPENED")
		isOpened = true
		body.hasKey = false		
		hide()  # Remove the coin from the scene
