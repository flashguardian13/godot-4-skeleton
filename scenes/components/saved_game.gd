extends Button

func update_display(info:Dictionary) -> void:
	$MarginContainer/HBoxContainer/NameLabel.text = info["name"]
	$MarginContainer/HBoxContainer/DateLabel.text = info["date"]
	self.custom_minimum_size = $MarginContainer.size
