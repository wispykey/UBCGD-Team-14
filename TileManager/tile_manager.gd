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


const BLUE_TILE = Vector2i(0,0) # Can change this
# IDEA: In the _light_up_tile function, we could increment a number that represents
#       the tile alternative on the tile set so it could be changing color or brightness

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Connect to signals that may request tile-specific functionality
	player.light_up_tile.connect(_on_player_light_up_tile)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# IDEA: Light-up tiles can make the tiles increase in brightness
func _on_player_light_up_tile(cell_pos: Vector2) -> void:
	floor.set_cell(cell_pos, 2, BLUE_TILE, 0)
