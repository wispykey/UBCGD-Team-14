extends Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var parent = find_parent("LevelSelection")
	var currentSelectedLevel = parent.getCurrentLevel()
	var selectedLevelInfo = parent.getLevelInfo()
	text = selectedLevelInfo
	var title = $"../LevelTitle" #
	title.text = currentSelectedLevel #
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
