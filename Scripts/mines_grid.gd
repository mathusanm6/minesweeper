extends TileMapLayer

class_name MinesGrid

signal flag_change(number_of_flags)
signal game_lost
signal game_won

const CELLS = {
	"1": Vector2i(0, 0),
	"2": Vector2i(1, 0),
	"3": Vector2i(2, 0),
	"4": Vector2i(3, 0),
	"5": Vector2i(4, 0),
	"6": Vector2i(0, 1),
	"7": Vector2i(1, 1),
	"8": Vector2i(2, 1),
	"CLEAR": Vector2i(3, 1),
	"MINE_RED": Vector2i(4, 1),
	"FLAG": Vector2i(0, 2),
	"MINE": Vector2i(1, 2),
	"DEFAULT": Vector2i(2, 2)
}

@export var columns = 8
@export var rows = 8
@export var number_of_mines = 10

const TILE_SET_ID = 0

var cells_with_mines = []
var cells_checked_recursively = []

func _ready() -> void:
	clear()
	
	for i in rows:
		for j in columns:
			var cell_coord = Vector2i(i - rows / 2, j - columns / 2)
			set_tile_cell(cell_coord, "DEFAULT")
	
	place_mines()

func _input(event: InputEvent):
	if !(event is InputEventMouseButton) || !event.is_pressed():
		return
	
	var clicked_cell_coord = local_to_map(get_local_mouse_position())
	
	if event.button_index == 1:
		on_cell_clicked(clicked_cell_coord)
	elif event.button_index == 2:
		print("PLACE FLAG")

func place_mines():
	for i in number_of_mines:
		var cell_coordinates = Vector2i(randi_range(-rows/2, rows/2 - 1), randi_range(-columns/2, columns/2 - 1))
		
		while cells_with_mines.has(cell_coordinates):
			cell_coordinates = Vector2i(randi_range(-rows/2, rows/2 - 1), randi_range(-columns/2, columns/2 - 1))
		
		cells_with_mines.append(cell_coordinates)
	
	for cell in cells_with_mines:
		erase_cell(cell)
		set_cell(cell, TILE_SET_ID, CELLS.DEFAULT, 1)
	
func set_tile_cell(cell_coord: Vector2i, cell_type: String):
	set_cell(cell_coord, TILE_SET_ID, CELLS[cell_type])

func on_cell_clicked(cell_coord: Vector2i):
	if cells_with_mines.any(func (cell): return cell.x == cell_coord.x && cell.y == cell_coord.y):
		lose(cell_coord)
		return
	
	cells_checked_recursively.append(cell_coord)
	handle_cells(cell_coord)

func handle_cells(cell_coord: Vector2i):
	var tile_data = get_cell_tile_data(cell_coord)
	
	if tile_data == null:
		return
	
	var cell_has_mine = tile_data.get_custom_data("has_mine")
	
	if cell_has_mine:
		return
	
	var mine_count = get_surrounding_cells_mine_count(cell_coord)
	
	if mine_count == 0:
		set_tile_cell(cell_coord, "CLEAR")
		var surrounding_cells = get_surrounding_cells(cell_coord)
		for cell in surrounding_cells:
			handle_surrounding_cell(cell)
	else:
		set_tile_cell(cell_coord, "%d" % mine_count)

func handle_surrounding_cell(cell_coord: Vector2i):
	if cells_checked_recursively.has(cell_coord):
		return
	
	cells_checked_recursively.append(cell_coord)
	handle_cells(cell_coord)
	
func get_surrounding_cells_mine_count(cell_coord: Vector2i):
	var mine_count = 0
	var surrounding_cells = get_surrounding_cells(cell_coord)
	for cell in surrounding_cells:
		var tile_data = get_cell_tile_data(cell)
		if tile_data and tile_data.get_custom_data("has_mine"):
			mine_count += 1
	return mine_count

func lose(cell_coord: Vector2i):
	game_lost.emit()
	
	for cell in cells_with_mines:
		set_tile_cell(cell, "MINE")
	
	set_tile_cell(cell_coord, "MINE_RED")
