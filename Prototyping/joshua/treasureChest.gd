extends Area2D

@onready var animation: AnimationPlayer = $"../AnimationPlayer"


var isOpened = false
func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player" and not isOpened and body.hasKey:  # Check if the touching object is the player
		print("CHEST OPENED")
		animation.play("chestContentsRevealed")
		isOpened = true
		body.hasKey = false		
		hide()
