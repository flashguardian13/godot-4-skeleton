extends MarginContainer

var board_marks:Array

func _ready():
	GameState.board_state_changed.connect(_on_board_state_changed)
	
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

	_on_board_state_changed()

func _on_tree_entered():
	Music.get_player().cross_fade_to("res://sounds/music/music_zapsplat_game_music_zen_calm_soft_arpeggios_013.mp3")

func _on_board_state_changed() -> void:
	_update_marks_from_state()
	_enable_all_unmarked()
	$UI/ResetButton.visible = (GameState.get_winner() != " ")

func _update_marks_from_state() -> void:
	print("[TicTacToe] _update_marks_from_state()")
	for y in board_marks.size():
		for x in board_marks[y].size():
			board_marks[y][x].get_node("Button").text = GameState.get_mark(x, y)

func _disable_all_marks() -> void:
	print("[TicTacToe] _disable_all_marks()")
	for mark in $TextureRect/GridContainer.get_children():
		mark.get_node("Button").disabled = true

func _enable_all_unmarked() -> void:
	print("[TicTacToe] _enable_all_unmarked()")
	for y in board_marks.size():
		for x in board_marks[y].size():
			board_marks[y][x].get_node("Button").disabled = GameState.get_mark(x, y) != " "

func _on_back_button_pressed():
	print("[TicTacToe] _on_back_button_pressed()")
	Transitions.start_transition("res://scenes/transitions/fade_to_black.tscn", "res://scenes/screens/main_menu.tscn")

func _on_reset_button_pressed():
	print("[TicTacToe] _on_reset_button_pressed()")
	GameState.reset_board()

func _on_board_marked(x:int, y:int, symbol:String) -> void:
	print("[TicTacToe] _on_board_marked(%s, %s, %s)" % [x, y, symbol])
	GameState.set_mark(x, y, symbol)

	if GameState.get_winner() != " ":
		return

	if symbol == "O":
		call_deferred("_do_computer_turn")
	else:
		_enable_all_unmarked()

func _do_computer_turn() -> void:
	print("[TicTacToe] _do_computer_turn()")
	var empty_spaces:Array = []
	for y in GameState.board_size():
		for x in GameState.board_size():
			if GameState.get_mark(x, y) == " ":
				empty_spaces.push_back(Vector2(x, y))

	var scores:Array = [[0, 0, 0], [0, 0, 0], [0, 0, 0]]
	var score:int = 0
	var o_count = 0
	var x_count = 0

	for y in GameState.board_size():
		var row:Array = GameState.get_row(y)
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

	for x in GameState.board_size():
		var column:Array = GameState.get_column(x)
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

	var diagonal:Array = GameState.get_diagonal()
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

	diagonal = GameState.get_reverse_diagonal()
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
