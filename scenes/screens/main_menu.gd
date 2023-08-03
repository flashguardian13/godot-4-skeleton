extends MarginContainer

const BG_SCROLL_SPEED:Vector2 = Vector2(10, 10)

func _ready():
	pass

func _process(delta):
	$ParallaxBackground.scroll_offset += BG_SCROLL_SPEED * delta

func _on_quit_button_pressed():
	print("[MainMenu] _on_quit_button_pressed")
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)

func _on_new_button_pressed():
	print("[MainMenu] _on_new_button_pressed")
	Transitions.start_transition("res://scenes/transitions/fade_to_black.tscn", "res://scenes/screens/tic_tac_toe.tscn")
