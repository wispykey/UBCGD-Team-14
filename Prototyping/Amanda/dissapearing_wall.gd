extends Node2D

@onready var tile = $TileMapLayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	#get_parent().get_node("DetectPushable").connect("object_in_place", turn_off)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func turn_off() -> void:
		visible = false
		tile.collision_enabled = false
		
func turn_on() -> void:
		visible = true
		tile.collision_enabled = true
