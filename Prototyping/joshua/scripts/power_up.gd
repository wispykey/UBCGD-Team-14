extends Area2D

@onready var powerUpSound = $AudioStreamPlayer2D
var isCollected = false

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player" and not isCollected:  # Check if the touching object is the player
		powerUpSound.play()
		body.powerUp()
		isCollected = true
		hide()  # Remove the coin from the scene
