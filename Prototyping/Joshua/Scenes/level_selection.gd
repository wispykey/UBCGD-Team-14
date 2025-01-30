extends Control

var levels = ["Spookesville", "Spellville", "Steamville"]
var current_index = 0

@onready var label = $VBoxContainer/LevelDisplayContainer/Label
@onready var back_button = $VBoxContainer/ButtonContainer/HBoxContainer/Back
@onready var forward_button = $VBoxContainer/ButtonContainer/HBoxContainer/Forward

# Called when the node enters the scene tree for the first time.
func _ready():
	update_label()

func update_label():
	label.text = levels[current_index]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_back_pressed() -> void:
	current_index = (current_index - 1 + levels.size()) % levels.size()
	update_label()

func _on_forward_pressed() -> void:
	current_index = (current_index + 1) % levels.size()
	update_label()
