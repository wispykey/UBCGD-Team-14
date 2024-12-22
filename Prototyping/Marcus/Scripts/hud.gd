extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func update_score(score):
	$ScoreLabel.text = str(score)

func update_life(life):
	$LifeLabel.text = str(life)


func _on_boss_fight_prototype_update_hud(score: int, life: int) -> void:
	update_score(score)
	update_life(life)
