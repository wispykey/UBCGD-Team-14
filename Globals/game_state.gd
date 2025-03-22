extends Node2D

const MAX_LIFE: float = 5.0
# Due to margins, ~90% HP still looks like 100% HP%. Hard-coded 'visual max' value.
const MAX_VISIBLE_LIFE: float = 4.4

var score: int = 0
var combo: int = 0
var life: float = MAX_VISIBLE_LIFE
var control_port : Rect2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	control_port = Rect2(0,0, 672, 480)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func update_combo(amount: int):
	# Reset on -1 flag, or if player is spamming to artificially inflating combo
	if amount == -1 or combo + amount > Conductor.num_beats_passed:
		combo = 0
	else:
		combo += amount
	GameEvents.combo_changed.emit()

func update_life(amount: float):
	# Guard to prevent multiple death bugs
	if life <= 0:
		return
	# Scale damage to use 'life' as progress bar's value (which has weird margins)
	var normalized_amount = amount * MAX_VISIBLE_LIFE / MAX_LIFE
	life = clamp(life + amount, 0 , MAX_VISIBLE_LIFE)
	GameEvents.life_changed.emit()
	if amount < 0:
		SFX.play_damage_taken()
	# Only emit signal once
	if life <= 0:
		GameEvents.player_died.emit()

func reset_life():
	life = MAX_VISIBLE_LIFE
