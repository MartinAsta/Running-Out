extends Node2D

@onready var ground_tile_map_layer = $GroundTileMapLayer
@onready var player = $Player
@onready var pause_area = $PauseArea
@onready var finish_line_area = $FinishLineArea

func _process(delta):
	if ground_tile_map_layer.position.x >= -2550:
		ground_tile_map_layer.position.x -= 1
		player.position.x -= 1
		pause_area.position.x -= 1
		finish_line_area.position.x -= 1
