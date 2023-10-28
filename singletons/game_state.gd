extends Node

# All data relating to the state of the active game instance is kept here where
# it can be accessed globally (as all Singletons can). One one game can be
# active at a time.

# ------------------------------------------------------------------------------
# These GameState elements are not game-specific and re-usable.
# ------------------------------------------------------------------------------

# This signal should be broadcasted whenever any aspect of the game state has
# changed. For more complex games, it may be desirable to additionally send
# other, more specific signals.
signal game_state_changed

# If true, a game is in progress.
var is_active:bool = false :
	get:
		return is_active

# ------------------------------------------------------------------------------
# These GameState elements are required, but should be modified to suit the game
# we are building.
# ------------------------------------------------------------------------------

# Rolls our game data up into a JSON-compatible object which can be saved to
# file.
func to_json() -> Dictionary:
	return { "board": _board_state }

# Given a game state in JSON form, sets the game state to match, restoring it to
# exactly the state it was in when previously saved.
func from_json(json:Dictionary):
	_board_state = json["board"]
	# Always do these.
	emit_signal("game_state_changed")
	is_active = true

# Resets the game to its beginning state (as when choosing "New Game").
func reset() -> void:
	for y in _board_state.size():
		for x in _board_state[y].size():
			_board_state[y][x] = " "
	# Always do these.
	emit_signal("game_state_changed")
	is_active = true

# ------------------------------------------------------------------------------
# These GameState elements are unique to our game. They should not be copied to
# other games.
# ------------------------------------------------------------------------------

# This is the state of the game board, tracking what marks are in which squares.
var _board_state:Array = [[" ", " ", " "], [" ", " ", " "], [" ", " ", " "]]

# Returns the dimensions of the board. (It's a square, so just one size.)
func board_size() -> int:
	return _board_state.size()

# Returns what mark is in the given square.
func get_mark(x:int, y:int) -> String:
	return _board_state[y][x]

# Sets the mark in the given square.
func set_mark(x:int, y:int, mark:String) -> void:
	_board_state[y][x] = mark
	emit_signal("game_state_changed")

# Determines if the game is in progress or has concluded with a winner or as a
# tie. Returns a single-character code representing the game resolution state:
# O: player victory
# X: computer victory
# ?: cat's game
# (space): undecided
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

# Returns a list of all the marks in the desired row.
func get_row(y:int) -> Array:
	return _board_state[y].duplicate()

# Returns a list of all the marks in the desired column.
func get_column(x:int) -> Array:
	return _board_state.map(func(row): return row[x])

# Returns a list of all the marks in the diagonal from the upper-left to the
# lower-right.
func get_diagonal() -> Array:
	var diagonal:Array = []
	for y in _board_state.size():
		diagonal.push_back(_board_state[y][y])
	return diagonal

# Returns a list of all the marks in the diagonal from the upper-right to the
# lower-left.
func get_reverse_diagonal() -> Array:
	var diagonal:Array = []
	for y in _board_state.size():
		diagonal.push_back(_board_state[y][_board_state.size() - y - 1])
	return diagonal

# Returns true if all elements of the Array equal the given value.
func _entire_array_equals(array:Array, value) -> bool:
	return array.all(func(x): return x == value)

# Returns false if any squares are unmarked, true otherwise.
func _is_board_full() -> bool:
	for y in _board_state.size():
		for x in _board_state[y].size():
			if _board_state[y][x] == " ":
				return false
	return true
