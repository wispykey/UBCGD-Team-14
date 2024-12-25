extends Node

var score: int = 0
var life: int = 10

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func update_life(amount: int):
	life += amount
	GameEvents.life_changed.emit()
	if life <= 0:
		GameEvents.player_died.emit()
