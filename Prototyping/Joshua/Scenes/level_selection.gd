extends Control

var levels = ["Spookesville", "Spellville", "Steamville"]
var level_images = [
	preload("res://Prototyping/Joshua/Assets/supernaturalPortal.png"),
	preload("res://Prototyping/Joshua/Assets/fantasyPortal.png"),
	preload("res://Prototyping/Joshua/Assets/steampunkPortal.png")
]
var current_index = 0

@onready var label = $VBoxContainer/LevelDisplayContainer/TextureRect/Label
@onready var texture_rect = $VBoxContainer/LevelDisplayContainer/TextureRect
@onready var back_button = $VBoxContainer/ButtonContainer/HBoxContainer/Back
@onready var forward_button = $VBoxContainer/ButtonContainer/HBoxContainer/Forward
@onready var audio_player = $AudioStreamPlayer2D

# Called when the node enters the scene tree for the first time.
func _ready():
	update_label()

func update_label():
	label.text = levels[current_index]
	texture_rect.texture = level_images[current_index]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_back_pressed() -> void:
	audio_player.play()
	current_index = (current_index - 1 + levels.size()) % levels.size()
	update_label()

func _on_forward_pressed() -> void:
	audio_player.play()
	current_index = (current_index + 1) % levels.size()
	update_label()
