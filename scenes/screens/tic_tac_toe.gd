extends MarginContainer

# The user-interface for our game. When building a new game from this skeleton,
# you aren't expected to keep this game, rather you should replace it with your
# own! As such, documentation here will be minimal.
#
# I call this the UI for the game, but in reality there's a fair amount of game
# behavior in here. It's probably a good idea to try and keep game state and
# presentation separate as much as possible, but this is for a skeleton so I was
# laaaaaaaazy.

# The path to our background music
# Sound from Zapsplat.com
const BG_MUSIC_PATH:String = "res://sounds/music/music_zapsplat_game_music_zen_calm_soft_arpeggios_013.mp3"

# A 2D Array holding references to our game pieces: the X/O marks.
var board_marks:Array

# A group of related sounds to be played whenever a new mark is made on the
# board.
var chalk_sounds:Array = []

# A local audio stream for playing non-positional sounds. Only used for one
# event, hence the name.
var board_erase_sound:AudioStream = null

func _ready():
	# Whenever the internal game state is updated, update our UI to match.
	GameState.board_state_changed.connect(_on_board_state_changed)
	# Pre-load game sounds.
	chalk_sounds = [
		ResourceLoader.load("res://sounds/chalkboard/zapsplat_office_chalk_draw_line_on_chalkboard_001_51971.mp3"),
		ResourceLoader.load("res://sounds/chalkboard/zapsplat_office_chalk_draw_line_on_chalkboard_005_51975.mp3"),
		ResourceLoader.load("res://sounds/chalkboard/zapsplat_office_chalk_draw_line_on_chalkboard_006_51976.mp3")
	]
	board_erase_sound = ResourceLoader.load("res://sounds/chalkboard/zapsplat_office_chalkboard_eraser_duster_rub_007_51983.mp3")
	# Fetch and store references to the game pieces or "marks" in the UI to make
	# later logic easier.
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
	# When any mark is clicked, it should mark the board for the player.
	for y in board_marks.size():
		for x in board_marks[y].size():
			var mark = board_marks[y][x]
			mark.board_marked.connect(_on_board_marked.bind(x, y, "O"))
			# Let each UI mark know what its board position is.
			mark.board_x = x
			mark.board_y = y
	# Fade-in game music
	Music.get_player().cross_fade_to(BG_MUSIC_PATH)
	# Now that everything is configured, go ahead and update the board.
	_on_board_state_changed()

func _on_board_state_changed() -> void:
	_update_marks_from_state()
	_enable_all_unmarked()
	# Only show the reset button when the current game is done
	$UI/ResetButton.visible = (GameState.get_winner() != " ")

func _update_marks_from_state() -> void:
	print("[TicTacToe] _update_marks_from_state()")
	# Iterate over all board marks
	for y in board_marks.size():
		for x in board_marks[y].size():
			var mark = board_marks[y][x]
			var button:Button = mark.get_node("Button")
			var chara:String = GameState.get_mark(x, y)
			# If this square's marking has changed from blank to an X or O ...
			if button.text != chara && chara != " ":
				# Play a marking sound
				var player:AudioStreamPlayer2D = mark.get_node("AudioStreamPlayer2D")
				player.stream = chalk_sounds.pick_random()
				player.play()
			# Set the button text to the appropriate mark
			button.text = chara

# Disables all marking buttons, making them unclickable.
func _disable_all_marks() -> void:
	print("[TicTacToe] _disable_all_marks()")
	for mark in $TextureRect/GridContainer.get_children():
		mark.get_node("Button").disabled = true

# Enables only those marking buttons whose squares are blank, allowing the
# player to click and mark them.
func _enable_all_unmarked() -> void:
	print("[TicTacToe] _enable_all_unmarked()")
	for y in board_marks.size():
		for x in board_marks[y].size():
			board_marks[y][x].get_node("Button").disabled = GameState.get_mark(x, y) != " "

func _on_back_button_pressed():
	print("[TicTacToe] _on_back_button_pressed()")
	Transitions.start_transition(Transitions.FADE_TO_BLACK, Transitions.MAIN_MENU)

func _on_reset_button_pressed():
	print("[TicTacToe] _on_reset_button_pressed()")
	# Start a new game
	GameState.reset_board()
	# Play a board-erasing sound. I chose to play this positionally, centered on
	# the board. No real reason.
	var player:AudioStreamPlayer2D = board_marks[1][1].get_node("AudioStreamPlayer2D")
	player.stream = board_erase_sound
	player.play()

func _on_board_marked(x:int, y:int, symbol:String) -> void:
	print("[TicTacToe] _on_board_marked(%s, %s, %s)" % [x, y, symbol])
	# Update the game state by marking the given square for the given player
	GameState.set_mark(x, y, symbol)
	# Check for game over
	if GameState.get_winner() != " ":
		return
	# Did the player just take their turn? If so, tell the computer to take its
	# turn.
	if symbol == "O":
		call_deferred("_do_computer_turn")
	# The computer just took its turn, so let the player have a turn.
	else:
		_enable_all_unmarked()

# Here is the logic used by the computer opponent to play against the player.
func _do_computer_turn() -> void:
	print("[TicTacToe] _do_computer_turn()")
	# A cinematic pause for effect while the computer opponent "thinks" about
	# where it will play.
	await get_tree().create_timer(1).timeout
	# Find all empty spaces
	var empty_spaces:Array = []
	for y in GameState.board_size():
		for x in GameState.board_size():
			if GameState.get_mark(x, y) == " ":
				empty_spaces.push_back(Vector2(x, y))
	# Prepare to assign a value to all squares on the board.
	var scores:Array = [[0, 0, 0], [0, 0, 0], [0, 0, 0]]
	var score:int = 0
	var o_count = 0
	var x_count = 0
	# Examine all rows
	for y in GameState.board_size():
		var row:Array = GameState.get_row(y)
		o_count = row.count("O")
		x_count = row.count("X")
		# Playing to this row would block the player from completing it
		if o_count > 0 && x_count < 1:
			score = o_count * o_count * 2
		# Playing to this row will bring us closer to completing it
		elif x_count > 0 && o_count < 1:
			score = x_count * x_count
		# It is still possible to win by playing to this row
		elif row.count(" ") == row.size():
			score = 1
		# There is no benefit to playing to this row
		else:
			score = 0
		# Increase the score of all squares in this row
		for x in row.size():
			scores[y][x] += score
	# Repeat the above logic, but for columns
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
	# Repeat the above logic, but for one of the diagonals
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
	# Repeat the above logic for the other diagonal
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
	# Debug output
	print("  scores: %s" % ", ".join(scores))
	# Sort squares into groups based on their scores
	var spaces_by_score:Dictionary = {}
	for space in empty_spaces:
		score = scores[space.y][space.x]
		if !spaces_by_score.has(score):
			spaces_by_score[score] = []
		spaces_by_score[score].push_back(space)
	# Choose a random square from the highest scoring group
	var best_score:int = spaces_by_score.keys().max()
	var pos:Vector2 = spaces_by_score[best_score].pick_random()
	# Mark that square!
	_on_board_marked(pos.x, pos.y, "X")
