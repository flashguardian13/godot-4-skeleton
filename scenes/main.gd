extends MarginContainer

func _ready():
	call_deferred("_show_splash_screen")

func _show_splash_screen():
	Transitions.start_transition("res://scenes/transitions/fade_to_black.tscn", "res://scenes/screens/splash.tscn")
