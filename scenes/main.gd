extends MarginContainer

# The main node is the node Godot first displays. Unlike transitions or screens,
# it is perpetually present, serving as the backbone of the scene tree for us,
# helping to keep our other nodes organized and layered properly. It should not
# display anything by default except for a black screen. Any display should be
# handled by other nodes.

func _ready():
	# The first thing we should show is the splash screen ... but let's wait and
	# give all of the other game elements a chance to load first.
	call_deferred("_show_splash_screen")

func _show_splash_screen():
	Transitions.start_transition(Transitions.TRANSITION_FADE_TO_BLACK, Transitions.SCREEN_SPLASH)

# Handle game close/quit requests here.
func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST || what == NOTIFICATION_WM_GO_BACK_REQUEST:
		Config.save()
		get_tree().quit()

func _input(event):
	if event is InputEventKey:
		var key_event:InputEventKey = event
		# Pressing the escape key should show the settings dialog.
		if key_event.pressed:
			if key_event.keycode == KEY_ESCAPE:
				print("[Main] showing settings ...")
				Popups.settings()
