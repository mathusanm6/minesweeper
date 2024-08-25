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

var is_game_finished = false
var cells_with_mines = []
var cells_with_flags = []
var flags_placed = 0
var cells_checked_recursively = []

func _ready() -> void:
	clear()
	initialize_grid()
	place_mines()

func initialize_grid() -> void:
	for i in rows:
		for j in columns:
			var cell_coord = Vector2i(i - rows / 2, j - columns / 2)
			set_tile_cell(cell_coord, "DEFAULT")

func _input(event: InputEvent):
	if is_game_finished:
		return
	
	if !(event is InputEventMouseButton) || !event.is_pressed():
		return
	
	var clicked_cell_coord = local_to_map(get_local_mouse_position())
	
	if event.button_index == 1:
		on_cell_clicked(clicked_cell_coord)
	elif event.button_index == 2:
		place_flag(clicked_cell_coord)

func place_mines():
	for i in number_of_mines:
		var cell_coordinates = random_cell_coordinates()
		while cells_with_mines.has(cell_coordinates):
			cell_coordinates = random_cell_coordinates()
		cells_with_mines.append(cell_coordinates)
	
	for cell in cells_with_mines:
		set_tile_cell(cell, "DEFAULT", 1)

func random_cell_coordinates() -> Vector2i:
	return Vector2i(randi_range(-rows/2, rows/2 - 1), randi_range(-columns/2, columns/2 - 1))
	
func set_tile_cell(cell_coord: Vector2i, cell_type: String, alternative_id: int = 0) -> void:
	erase_cell(cell_coord)
	set_cell(cell_coord, TILE_SET_ID, CELLS[cell_type], alternative_id)

func on_cell_clicked(cell_coord: Vector2i):
	if cells_with_flags.has(cell_coord):
		return
	
	if is_mine_at(cell_coord):
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
	var surrounding_cells = get_surroundings_cells_to_check(cell_coord)
	for cell in surrounding_cells:
		var tile_data = get_cell_tile_data(cell)
		if tile_data and tile_data.get_custom_data("has_mine"):
			mine_count += 1
	return mine_count

func lose(cell_coord: Vector2i):
	game_lost.emit()
	is_game_finished = true
	for cell in cells_with_mines:
		set_tile_cell(cell, "MINE")
	set_tile_cell(cell_coord, "MINE_RED")

func is_mine_at(cell_coord: Vector2i) -> bool:
	return cells_with_mines.has(cell_coord)
	
func place_flag(cell_coord: Vector2i):
	var tile_data = get_cell_tile_data(cell_coord)
	var atlas_coord = get_cell_atlas_coords(cell_coord)
	var is_empty_cell = atlas_coord == CELLS.DEFAULT
	var is_flag_cell = atlas_coord == CELLS.FLAG

	if !is_empty_cell and !is_flag_cell:
		return
	
	if is_flag_cell:
		set_tile_cell(cell_coord, "DEFAULT")
		cells_with_flags.erase(cell_coord)
		flags_placed -= 1
	elif is_empty_cell:
		if flags_placed == number_of_mines:
			return
		
		flags_placed += 1
		set_tile_cell(cell_coord, "FLAG")
		cells_with_flags.append(cell_coord)
	
	flag_change.emit(flags_placed)
	
	var count = 0
	for flag_cell in cells_with_flags:
		for mine in cells_with_mines:
			if flag_cell == mine:
				count += 1
	
	if count == cells_with_mines.size():
		win()

func win():
	is_game_finished = true
	game_won.emit()

func get_surroundings_cells_to_check(current_cell: Vector2i):
	var target_cell
	var surrounding_cells = []
	
	for y in range(-1, 2):
		for x in range(-1, 2):
			if y == 0 and x == 0:
				continue
			target_cell = current_cell + Vector2i(x, y)
			surrounding_cells.append(target_cell)
	
	return surrounding_cells
