extends MarginContainer

func _ready():
	pass

func _process(_delta):
	pass

func _on_back_button_pressed():
	Transitions.start_transition("res://scenes/transitions/fade_to_black.tscn", "res://scenes/screens/main_menu.tscn")
