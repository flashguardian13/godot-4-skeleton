extends MarginContainer

var board_state:Array = [[" ", " ", " "], [" ", " ", " "], [" ", " ", " "]]
var board_marks:Array

func _ready():
	board_marks = [
		[
			$TextureRect/GridContainer/BoardMark,
			$TextureRect/GridContainer/BoardMark2,
			$TextureRect/GridContainer/BoardMark3
		],
		[
			$TextureRect/GridContainer/BoardMark4,
			$TextureRect/GridContainer/BoardMark5,
			$TextureRect/GridContainer/BoardMark6
		],
		[
			$TextureRect/GridContainer/BoardMark7,
			$TextureRect/GridContainer/BoardMark8,
			$TextureRect/GridContainer/BoardMark9
		]
	]

	for y in board_marks.size():
		for x in board_marks[y].size():
			var mark = board_marks[y][x]
			mark.board_marked.connect(_on_board_marked.bind(x, y, "O"))
			mark.board_x = x
			mark.board_y = y

	reset()

func reset() -> void:
	print("[TicTacToe] reset()")
	board_state = [[" ", " ", " "], [" ", " ", " "], [" ", " ", " "]]
	_update_marks_from_state()
	_enable_all_unmarked()
	$UI/ResetButton.visible = false

func _update_marks_from_state() -> void:
	print("[TicTacToe] _update_marks_from_state()")
	for y in board_marks.size():
		for x in board_marks[y].size():
			board_marks[y][x].get_node("Button").text = board_state[y][x]

func _disable_all_marks() -> void:
	print("[TicTacToe] _disable_all_marks()")
	for mark in $TextureRect/GridContainer.get_children():
		mark.get_node("Button").disabled = true

func _enable_all_unmarked() -> void:
	print("[TicTacToe] _enable_all_unmarked()")
	for y in board_marks.size():
		for x in board_marks[y].size():
			board_marks[y][x].get_node("Button").disabled = board_state[y][x] != " "

func _on_back_button_pressed():
	print("[TicTacToe] _on_back_button_pressed()")
	Transitions.start_transition("res://scenes/transitions/fade_to_black.tscn", "res://scenes/screens/main_menu.tscn")

func _on_reset_button_pressed():
	print("[TicTacToe] _on_reset_button_pressed()")
	reset()

func _on_board_marked(x:int, y:int, symbol:String) -> void:
	print("[TicTacToe] _on_board_marked(%s, %s, %s)" % [x, y, symbol])
	board_state[y][x] = symbol
	_update_marks_from_state()
	_disable_all_marks()

	if _get_winner() != " ":
		$UI/ResetButton.visible = true
		return

	if symbol == "O":
		call_deferred("_do_computer_turn")
	else:
		_enable_all_unmarked()

func _get_winner() -> String:
	print("[TicTacToe] _get_winner()")
	for y in board_state.size():
		var row:Array = _get_row(y)
		if _entire_array_equals(row, "O"):
			return "O"
		if _entire_array_equals(row, "X"):
			return "X"

	for x in board_state.size():
		var column:Array = _get_column(x)
		if _entire_array_equals(column, "O"):
			return "O"
		if _entire_array_equals(column, "X"):
			return "X"

	var diagonal:Array = _get_diagonal()
	if _entire_array_equals(diagonal, "O"):
		return "O"
	if _entire_array_equals(diagonal, "X"):
		return "X"

	diagonal = _get_reverse_diagonal()
	if _entire_array_equals(diagonal, "O"):
		return "O"
	if _entire_array_equals(diagonal, "X"):
		return "X"

	if _is_board_full():
		return "?"

	return " "

func _get_row(y:int) -> Array:
	return board_state[y].duplicate()

func _get_column(x:int) -> Array:
	return board_state.map(func(row): return row[x])

func _get_diagonal() -> Array:
	var diagonal:Array = []
	for y in board_state.size():
		diagonal.push_back(board_state[y][y])
	return diagonal

func _get_reverse_diagonal() -> Array:
	var diagonal:Array = []
	for y in board_state.size():
		diagonal.push_back(board_state[y][board_state.size() - y - 1])
	return diagonal

func _entire_array_equals(array:Array, value) -> bool:
	return array.all(func(x): return x == value)

func _is_board_full() -> bool:
	for y in board_state.size():
		for x in board_state[y].size():
			if board_state[y][x] == " ":
				return false
	return true

func _do_computer_turn() -> void:
	print("[TicTacToe] _do_computer_turn()")
	var empty_spaces:Array = []
	for y in board_state.size():
		for x in board_state[y].size():
			if board_state[y][x] == " ":
				empty_spaces.push_back(Vector2(x, y))

	var scores:Array = [[0, 0, 0], [0, 0, 0], [0, 0, 0]]
	var score:int = 0
	var o_count = 0
	var x_count = 0

	for y in board_state.size():
		var row:Array = _get_row(y)
		o_count = row.count("O")
		x_count = row.count("X")
		if o_count > 0 && x_count < 1:
			score = o_count * o_count * 2
		elif x_count > 0 && o_count < 1:
			score = x_count * x_count
		elif row.count(" ") == row.size():
			score = 1
		else:
			score = 0
		for x in row.size():
			scores[y][x] += score

	for x in board_state.size():
		var column:Array = _get_column(x)
		o_count = column.count("O")
		x_count = column.count("X")
		if o_count > 0 && x_count < 1:
			score = o_count * o_count * 2
		elif x_count > 0 && o_count < 1:
			score = x_count * x_count
		elif column.count(" ") == column.size():
			score = 1
		else:
			score = 0
		for y in column.size():
			scores[y][x] += score

	var diagonal:Array = _get_diagonal()
	o_count = diagonal.count("O")
	x_count = diagonal.count("X")
	if o_count > 0 && x_count < 1:
		score = o_count * o_count * 2
	elif x_count > 0 && o_count < 1:
		score = x_count * x_count
	elif diagonal.count(" ") == diagonal.size():
		score = 1
	else:
		score = 0
	for y in diagonal.size():
		scores[y][y] += score

	diagonal = _get_reverse_diagonal()
	o_count = diagonal.count("O")
	x_count = diagonal.count("X")
	if o_count > 0 && x_count < 1:
		score = o_count * o_count * 2
	elif x_count > 0 && o_count < 1:
		score = x_count * x_count
	elif diagonal.count(" ") == diagonal.size():
		score = 1
	else:
		score = 0
	for y in diagonal.size():
		scores[y][diagonal.size() - y - 1] += score

	print("  scores: %s" % ", ".join(scores))

	var spaces_by_score:Dictionary = {}
	for space in empty_spaces:
		score = scores[space.y][space.x]
		if !spaces_by_score.has(score):
			spaces_by_score[score] = []
		spaces_by_score[score].push_back(space)
	var best_score:int = spaces_by_score.keys().max()

	var pos:Vector2 = spaces_by_score[best_score].pick_random()
	_on_board_marked(pos.x, pos.y, "X")
