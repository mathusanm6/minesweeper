extends TileMapLayer

class_name MinesGrid

enum Cell {
	ONE,
	TWO,
	THREE,
	FOUR,
	FIVE,
	SIX,
	SEVEN,
	EIGHT,
	CLEAR,
	MINE_RED,
	FLAG,
	MINE,
	DEFAULT
}

const CELLS = {
	Cell.ONE: Vector2i(0, 0),
	Cell.TWO: Vector2i(1, 0),
	Cell.THREE: Vector2i(2, 0),
	Cell.FOUR: Vector2i(3, 0),
	Cell.FIVE: Vector2i(4, 0),
	Cell.SIX: Vector2i(0, 1),
	Cell.SEVEN: Vector2i(1, 1),
	Cell.EIGHT: Vector2i(2, 1),
	Cell.CLEAR: Vector2i(3, 1),
	Cell.MINE_RED: Vector2i(4, 1),
	Cell.FLAG: Vector2i(0, 2),
	Cell.MINE: Vector2i(1, 2),
	Cell.DEFAULT: Vector2i(2, 2)
}

@export var columns = 8
@export var rows = 8
@export var number_of_mines = 10

const TILE_SET_ID = 0

func _ready() -> void:
	clear()
	
	for i in rows:
		for j in columns:
			var cell_coord = Vector2i(i - rows / 2, j - columns / 2)
			set_tile_cell(cell_coord, Cell.DEFAULT)

func set_tile_cell(cell_coord: Vector2i, cell_type: Cell):
	set_cell(cell_coord, TILE_SET_ID, CELLS[cell_type])
