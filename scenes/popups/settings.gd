extends Window

func _ready():
	pass

func _process(delta):
	pass

func _input(event):
	if event is InputEventKey:
		var key_event:InputEventKey = event
		if key_event.pressed:
			if key_event.keycode == KEY_ESCAPE:
				hide()

func _on_close_requested():
	hide()

func _on_go_back_requested():
	hide()
