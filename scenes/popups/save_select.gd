extends Window

var saved_game_button:PackedScene = preload("res://scenes/ui/saved_game.tscn")

signal resolved(result)

func _on_about_to_popup():
	_update_saved_game_buttons()

func _update_saved_game_buttons() -> void:
	var index:int = 0
	var children:Array = $ScrollContainer/VBoxContainer.get_children()
	children.erase($ScrollContainer/VBoxContainer/SaveAsButton)
	var save_names:Array = Saves.get_save_names()
	var info:Dictionary
	var btn:Button
	while index < children.size() || index < save_names.size():
		if index < save_names.size():
			info = Saves.get_save_info(save_names[index])
		if index < children.size():
			btn = children[index]
		else:
			btn = saved_game_button.instantiate()
			btn.pressed.connect(_on_saved_game_pressed.bind(info["name"]))
			$ScrollContainer/VBoxContainer.add_child(btn)
		if index < save_names.size():
			btn.update_display(info)
		else:
			btn.pressed.disconnect(_on_saved_game_pressed)
			$ScrollContainer/VBoxContainer.remove_child(btn)
			btn.queue_free()
		index += 1

func _on_close_requested():
	emit_signal("resolved", { "selected": false })
	hide()

func _on_go_back_requested():
	emit_signal("resolved", { "selected": false })
	hide()

func _on_save_as_button_pressed():
	pass # Replace with function body.

func _on_saved_game_pressed(name:String):
	emit_signal("resolved", { "selected": true, "name": name })