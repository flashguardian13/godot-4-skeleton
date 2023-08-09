extends Node

signal board_state_changed

var _board_state:Array = [[" ", " ", " "], [" ", " ", " "], [" ", " ", " "]]

func to_json() -> Dictionary:
	return { "board": _board_state }

func from_json(json:Dictionary):
	_board_state = json["board"]

func reset_board() -> void:
	for y in _board_state.size():
		for x in _board_state[y].size():
			_board_state[y][x] = " "
	emit_signal("board_state_changed")

func board_size() -> int:
	return _board_state.size()

func get_mark(x:int, y:int) -> String:
	return _board_state[y][x]

func set_mark(x:int, y:int, mark:String) -> void:
	_board_state[y][x] = mark
	emit_signal("board_state_changed")

func get_winner() -> String:
	for y in _board_state.size():
		var row:Array = get_row(y)
		if _entire_array_equals(row, "O"):
			return "O"
		if _entire_array_equals(row, "X"):
			return "X"

	for x in _board_state.size():
		var column:Array = get_column(x)
		if _entire_array_equals(column, "O"):
			return "O"
		if _entire_array_equals(column, "X"):
			return "X"

	var diagonal:Array = get_diagonal()
	if _entire_array_equals(diagonal, "O"):
		return "O"
	if _entire_array_equals(diagonal, "X"):
		return "X"

	diagonal = get_reverse_diagonal()
	if _entire_array_equals(diagonal, "O"):
		return "O"
	if _entire_array_equals(diagonal, "X"):
		return "X"

	if _is_board_full():
		return "?"

	return " "

func get_row(y:int) -> Array:
	return _board_state[y].duplicate()

func get_column(x:int) -> Array:
	return _board_state.map(func(row): return row[x])

func get_diagonal() -> Array:
	var diagonal:Array = []
	for y in _board_state.size():
		diagonal.push_back(_board_state[y][y])
	return diagonal

func get_reverse_diagonal() -> Array:
	var diagonal:Array = []
	for y in _board_state.size():
		diagonal.push_back(_board_state[y][_board_state.size() - y - 1])
	return diagonal

func _entire_array_equals(array:Array, value) -> bool:
	return array.all(func(x): return x == value)

func _is_board_full() -> bool:
	for y in _board_state.size():
		for x in _board_state[y].size():
			if _board_state[y][x] == " ":
				return false
	return true
