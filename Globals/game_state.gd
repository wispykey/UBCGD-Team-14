extends Node2D

var score: int = 0
var life: int = 10
var viewport

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	viewport = get_viewport_rect()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func update_life(amount: int):
	life += amount
	GameEvents.life_changed.emit()
	if life <= 0:
		GameEvents.player_died.emit()
