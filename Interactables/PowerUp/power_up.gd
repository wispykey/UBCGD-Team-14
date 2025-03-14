extends Area2D

@onready var power_up_sound = $AudioStreamPlayer2D
var is_collected = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if not is_collected:  # Check if the touching object is the player
		power_up_sound.play()
		body.power_up()
		is_collected = true
		hide()  # Remove the coin from the scene
