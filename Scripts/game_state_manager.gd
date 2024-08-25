extends Node

@export var mines_grid: MinesGrid
@export var ui: UI

@onready var timer: Timer = $Timer

var time_elapsed = 0

func _ready() -> void:
	mines_grid.game_lost.connect(on_game_lost)
	mines_grid.game_won.connect(on_game_won)
	mines_grid.flag_change.connect(on_flag_change)
	ui.set_mines_count(mines_grid.number_of_mines)

func _on_timer_timeout() -> void:
	time_elapsed += 1
	ui.set_timer_count(time_elapsed)

func on_flag_change(flags_count: int):
	ui.set_mines_count(mines_grid.number_of_mines - flags_count)

func on_game_lost():
	timer.stop()
	ui.game_lost()

func on_game_won():
	timer.stop()
	ui.game_won()
