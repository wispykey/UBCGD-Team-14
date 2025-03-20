extends Node2D

const MAX_LIFE: float = 5.0
# Due to margins, ~90% HP still looks like 100% HP%. Hard-coded 'visual max' value.
const MAX_VISIBLE_LIFE: float = 4.4

var score: int = 0
var life: float = MAX_VISIBLE_LIFE
var control_port : Rect2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	control_port = Rect2(0,0, 672, 480)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func update_life(amount: float):
	# TODO: Uncomment this when death is functional
	#if life <= 0: # Only die once
		#return
	life = clamp(life + amount, 0 , MAX_VISIBLE_LIFE)
	GameEvents.life_changed.emit()
	print(life)
	
	if amount < 0:
		SFX.play_damage_taken()
	if life <= 0:
		GameEvents.player_died.emit()
