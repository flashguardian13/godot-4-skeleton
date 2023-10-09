extends CenterContainer

signal board_marked

# Custom properties for this mark's x/y position on the tic-tac-toe board. The
# "board_" prefix disambiguates these properties from other inherent Godot
# properties relating to the UI.
var board_x:int = 0 :
	set(value):
		board_x = value
	get:
		return board_x
var board_y:int = 0 :
	set(value):
		board_y = value
	get:
		return board_y

# Mouse events will be handled by our parent.
func _on_button_pressed():
	print("[BoardMark] _on_button_pressed")
	emit_signal("board_marked")
