extends ConfirmationDialog

signal resolved(result)

func _ready():
	pass

func _on_confirmed():
	hide()
	emit_signal("resolved", true)

func _on_canceled():
	hide()
	emit_signal("resolved", false)
