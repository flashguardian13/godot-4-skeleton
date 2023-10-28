extends Button

# A clickable, visual representation of a saved game in the UI, intended for use
# by the Save Select dialog.

# Given information about a saved game, update our display elements using that
# information.
func update_display(info:Dictionary) -> void:
	$MarginContainer/HBoxContainer/NameLabel.text = info["name"]
	$MarginContainer/HBoxContainer/DateLabel.text = info["date"]
	self.custom_minimum_size = $MarginContainer.size
