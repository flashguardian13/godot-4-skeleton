extends AcceptDialog

signal verdict(result)

func _ready():
	add_button("No", true, "denied")
	add_cancel_button("Cancel")

func _on_canceled():
	emit_signal("verdict", "canceled")

func _on_confirmed():
	emit_signal("verdict", "confirmed")

func _on_custom_action(action):
	emit_signal("verdict", action)
	hide()
