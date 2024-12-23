extends Area2D

@onready var animation: AnimationPlayer = $"../AnimationPlayer"


var is_opened = false
func _on_body_entered(body: Node2D) -> void:
	if not is_opened and body.has_key:  # Check if the touching object is the player
		print("CHEST OPENED")
		animation.play("chestContentsRevealed")
		is_opened = true
		body.has_key = false		
		hide()
