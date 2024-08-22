extends TileMapLayer

class_name MinesGrid

@export var columns = 8
@export var rows = 8
@export var number_of_mines = 10

const TILE_SET_ID = 0

func _ready() -> void:
	clear()
