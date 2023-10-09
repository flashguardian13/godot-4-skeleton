extends ConfirmationDialog

# General purpose popup dialog presenting the user with a yes/no choice. The
# user's choice is not handled here; instead, it is returned to the caller for
# handling. The caller should listen for the "resolved" signal and expect a
# boolean: true for acceptance, false for rejection.

signal resolved(result)

func _ready():
	pass

func _on_confirmed():
	hide()
	emit_signal("resolved", true)

func _on_canceled():
	hide()
	emit_signal("resolved", false)
