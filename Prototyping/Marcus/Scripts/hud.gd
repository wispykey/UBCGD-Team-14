extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameEvents.score_changed.connect(_on_score_changed)
	GameEvents.life_changed.connect(_on_life_changed)
	
	$ScoreLabel.text = str(GameState.score)
	$LifeLabel.text = str(GameState.life)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_score_changed():
	$ScoreLabel.text = str(GameState.score)

func _on_life_changed():
	$LifeLabel.text = str(GameState.life)
