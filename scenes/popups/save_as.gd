extends ConfirmationDialog

# Prompts the user for a name for a saved game. The caller should listen for the
# "resolved" signal and expect a Dictionary with the following keys:
# entered: true if the user entered a name, false if the user canceled
# name: the game name chosen by the user

signal resolved(info)

func _ready():
  # Tells this dialog where its text box is.
	register_text_enter($VBoxContainer/LineEdit)

func _on_canceled():
	print("[SaveAs] _on_canceled")
	hide()
	emit_signal("resolved", { "entered": false })

func _on_confirmed():
	print("[SaveAs] _on_confirmed")
	hide()
	emit_signal("resolved", { "entered": true, "name": $VBoxContainer/LineEdit.text })

func _on_custom_action(action:StringName):
	print("[SaveAs] _on_custom_action('%s')" % action)
	match action:
		"?":
			hide()
			emit_signal("resolved", { "entered": true, "name": $VBoxContainer/LineEdit.text })
		_:
			assert(false, "[SaveAs] unrecognized action: '%s'" % action)
