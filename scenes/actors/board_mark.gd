extends CenterContainer

func _ready():
	pass

func _process(delta):
	pass

func _on_button_pressed():
	print("[BoardMark] _on_button_pressed")
	if $Button.text == 'X':
		$Button.text = 'O'
	elif $Button.text == 'O':
		$Button.text = ' '
	else:
		$Button.text = 'X'
