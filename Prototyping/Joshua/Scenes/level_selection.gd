extends Control

var levels = ["Spookesville", "Spellville", "Steamville"]
var current_index = 0
var level_map = {
	"Spookesville": {	"scene": "res://Prototyping/Example/ExampleLevel.tscn",
						"image": preload("res://Prototyping/Joshua/Assets/supernaturalPortal.png"),
						"info": "A mist-shrouded realm where flickering lanterns cast eerie glows over crumbling mausoleums. Once a haven for harmonious ghostly existence, the land is now gripped by turmoil as a vengeful spirit rises, threatening to shatter the delicate peace"
						},
	"Spellville": { 		"scene": "res://Prototyping/Example/ExampleLevelTwo.tscn",
						"image": preload("res://Prototyping/Joshua/Assets/fantasyPortal.png"),
						"info": "A vibrant fantasy town where magic weaves through everyday life, from glowing cobblestone streets to floating marketplaces. Unbeknownst to its residents, a rogue magic now threatens to unravel its harmony."
						},
	"Steamville": {		"scene": "",
						"image": preload("res://Prototyping/Joshua/Assets/steampunkPortal.png"),
						"info": "A steampunk metropolis of towering brass spires, airships, and intricate machinery, where innovation thrives amidst the hum of gears. Beneath its gleaming surface, a shadowy faction seeks to sabotage the city's power core, threatening to plunge it into darkness."
						}
}

@onready var label = $VBoxContainer/LevelDisplayContainer/TextureRect/SelectionLabel
@onready var texture_rect = $VBoxContainer/LevelDisplayContainer/TextureRect
@onready var back_button = $VBoxContainer/ButtonContainer/HBoxContainer/Back
@onready var forward_button = $VBoxContainer/ButtonContainer/HBoxContainer/Forward

@onready var info_box = $InfoBox
# Called when the node enters the scene tree for the first time.
func _ready():
	info_box.hide()
	update_label()

func update_label():
	label.text = levels[current_index]
	texture_rect.texture = level_map[levels[current_index]].image

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept") and info_box.visible and level_map[levels[current_index]].scene:
		get_tree().change_scene_to_file(level_map[levels[current_index]].scene)
		
	elif Input.is_action_just_pressed("ui_accept"):
		selectLevel()
		
	if Input.is_action_just_pressed("ui_cancel"):
		info_box.hide()
		
func selectLevel() -> void:
	SFX.play_UI_accept()
	print("Level selected: ", levels[current_index])
	showInfo()
	
	#if Input.is_action_just_pressed("ui_accept") and info_box.visible and level_map[levels[current_index]].scene:
		#get_tree().change_scene_to_file(level_map[levels[current_index]].scene)
		
		
	# switch scene
	#if (level_map[levels[current_index]].scene):
		#get_tree().change_scene_to_file(level_map[levels[current_index]].scene)

func _on_back_pressed() -> void:
	SFX.play_UI_switch_level()
	current_index = (current_index - 1 + levels.size()) % levels.size()
	update_label()

func _on_forward_pressed() -> void:
	SFX.play_UI_switch_level()
	current_index = (current_index + 1) % levels.size()
	update_label()

func showInfo():
	info_box.update() # update information in info box
	info_box.show()

func getCurrentLevel():
	return levels[current_index]
	
func getLevelInfo():
	return level_map[levels[current_index]].info
