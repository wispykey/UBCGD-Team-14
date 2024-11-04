@tool
extends Node2D

@onready var child = load("res://addons/song_block/SongBlock.tscn").instantiate()

@export_group("Dimensions")
@export var width: float = 600:
	set(value) :
		width = value
		if height != ((value/600) * 125):
			height = (value/600) * 125
		_resize_sprite_collision()
@export var height: float = 125:
	set(value) :
		height = value
		if width != ((value/125) * 600):
			width = (value/125) * 600
		_resize_sprite_collision()
@export_group("Information")
@export var title: String = "Seven Nation Army":
	set(value) :
		title = value
		_change_title()
@export var author: String = "The White Stripes":
	set(value) :
		author = value
		_change_author()
@export var difficulty: String = "Hard":
	set(value) :
		difficulty = value
		_change_difficulty()
@export var time: String = "3 min":
	set(value) :
		time = value
		_change_time()
@export var texture: Texture2D = load("res://Prototyping/Andrew_Mainella/Assets/Pump_It_Up.jpg"):
	set(value) :
		texture = value
		_change_texture()

func _resize_sprite_collision() -> void:
	self.scale = Vector2(width/600, height/125)

var container: Panel

func _change_title() -> void:
	if (container != null):
		var TitleLabel = container.get_node("TitleLabel")
		TitleLabel.text = title

func _change_author() -> void:
	if (container != null):
		var AuthorLabel = container.get_node("AuthorLabel")
		AuthorLabel.text = author

func _change_difficulty() -> void:
	if (container != null):
		var DifficultyLabel = container.get_node("DifficultyLabel")
		DifficultyLabel.text = difficulty

func _change_time() -> void:
	if (container != null):
		var TimeLabel = container.get_node("TimeLabel")
		TimeLabel.text = time

func _change_texture() -> void:
	if (container != null):
		var ImageComp = container.get_node("Image")
		ImageComp.texture = texture
		ImageComp.scale.x = 95/ImageComp.texture.get_size().x
		ImageComp.scale.y = 95/ImageComp.texture.get_size().y

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# adds the main view
	self.add_child(child)
	# sets the width and height to be inline with the exported variables
	self.scale = Vector2(width/600, height/125)
	
	# finds the parent of all the text and images
	container = self.get_node("SongBlockArea2D").get_node("Panel")
	
	# Adds the infomration from the exported variables

	var TitleLabel = container.get_node("TitleLabel")
	TitleLabel.text = title
	
	var AuthorLabel = container.get_node("AuthorLabel")
	AuthorLabel.text = author
	
	var DifficultyLabel = container.get_node("DifficultyLabel")
	DifficultyLabel.text = difficulty
	
	var TimeLabel = container.get_node("TimeLabel")
	TimeLabel.text = time
	
	var ImageComp: Sprite2D = container.get_node("Image")
	ImageComp.texture = texture
	ImageComp.scale.x = 95/ImageComp.texture.get_size().x
	ImageComp.scale.y = 95/ImageComp.texture.get_size().y
