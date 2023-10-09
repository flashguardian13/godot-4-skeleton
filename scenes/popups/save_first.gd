extends AcceptDialog

# Asks the user if they would like to save the current game before it goes away.
# The response is returned to the caller via the "verdict" signal. Caller should
# expect one of three Strings:
#
# canceled: user no longer wants to continue with the game-ending action
# confirmed: user wants to save before the game-ending action is taken
# denied: user does not want to save, go ahead and end the current game
#
# At this time, no checking is done to see if the game state has actually
# changed before prompting. Such logic is not trivial and highly game-specific.

signal verdict(result)

func _ready():
	# Buttons are added manually to achieve desired left-to-right ordering
	add_button("No", true, "denied")
	add_cancel_button("Cancel")

func _on_canceled():
	emit_signal("verdict", "canceled")

func _on_confirmed():
	emit_signal("verdict", "confirmed")

func _on_custom_action(action):
	hide() # hiding is implicit for other events, but not this
	emit_signal("verdict", action)
