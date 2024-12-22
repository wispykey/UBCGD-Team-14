extends Node2D

"""
Tile-specific functionality should exist here.

This class will listen for signals requesting tile-specific operations.
"""

# These child nodes should always be added in the level scene
@onready var walls: TileMapLayer = $Walls
@onready var floor: TileMapLayer = $Floor
# A single Player should always exist
@onready var player = %Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Connect to signals that may request tile-specific functionality
	# TODO: Connect to a signal from Player for lighting up tiles
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# TODO: Implement light-up tiles
