extends CanvasLayer

@onready var level_title_label = find_child("LevelTitle")
@onready var level_description_label = find_child("LevelDescription")
@onready var level_preview_image = find_child("LevelPreviewImage")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func update():
	var parent = find_parent("LevelSelection")
	var currentSelectedLevel = parent.getCurrentLevel()
	var selectedLevelInfo = parent.getLevelInfo()
	
	level_description_label.text = selectedLevelInfo
	level_title_label.text = currentSelectedLevel
	level_preview_image.texture = parent.getCurrentLevelPreview()
