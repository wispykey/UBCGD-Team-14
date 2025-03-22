extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameEvents.score_changed.connect(_on_score_changed)
	GameEvents.combo_changed.connect(_on_combo_changed)
	GameEvents.life_changed.connect(_on_life_changed)
	GameState.reset_life()
	
	$ScoreLabel.text = str(GameState.score)
	$LifeProgress.value = GameState.life;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func start_beat_indicator():
	Conductor.quarter_beat.connect($BeatIndicator.restart_anim)

func _on_score_changed():
	$ScoreLabel.text = str(GameState.score)
	
func _on_combo_changed():
	$Combo.text = str(GameState.combo)

func _on_life_changed():
	$LifeProgress.value = GameState.life;
