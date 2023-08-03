extends CenterContainer

signal board_marked

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

func _on_button_pressed():
	print("[BoardMark] _on_button_pressed")
	emit_signal("board_marked")
