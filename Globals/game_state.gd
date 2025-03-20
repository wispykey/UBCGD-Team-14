extends Node2D

const MAX_LIFE: int = 5

var score: int = 0
var life: int = MAX_LIFE
var control_port : Rect2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	control_port = Rect2(0,0, 672, 480)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func update_life(amount: int):
	# TODO: Uncomment this when death is functional
	#if life <= 0: # Only die once
		#return
	life = max(0, life + amount)
	SFX.play_damage_taken()
	GameEvents.life_changed.emit()
	if life <= 0:
		GameEvents.player_died.emit()
