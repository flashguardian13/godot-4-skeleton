extends MarginContainer

func _ready():
	await get_tree().create_timer(3).timeout
	Transitions.start_transition("res://scenes/transitions/fade_to_black.tscn", "res://scenes/screens/main_menu.tscn")
