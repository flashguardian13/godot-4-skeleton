extends MarginContainer

# A simple splash screen. Waits three seconds, then goes to the main menu.

func _ready():
	await get_tree().create_timer(3).timeout
	Transitions.start_transition(Transitions.FADE_TO_BLACK, Transitions.MAIN_MENU)
