extends Window

var saved_game_button:PackedScene = preload("res://scenes/components/saved_game.tscn")

signal resolved(result)

var select_mode:String = "load"

func set_select_mode(mode:String) -> void:
	select_mode = mode
	match select_mode:
		"load":
			$ScrollContainer/VBoxContainer/SaveAsButton.visible = false
		"save":
			$ScrollContainer/VBoxContainer/SaveAsButton.visible = true
		_:
			assert(false, "[SaveSelect] Unexpected selection mode: '' %s" % mode)

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
			btn.pressed.disconnect(_on_saved_game_pressed)
		else:
			btn = saved_game_button.instantiate()
			$ScrollContainer/VBoxContainer.add_child(btn)

		if index < save_names.size():
			btn.update_display(info)
			print("[SaveSelect] connecting save game button for '%s'" % info["name"])
			btn.pressed.connect(_on_saved_game_pressed.bind(info["name"]))
		else:
			$ScrollContainer/VBoxContainer.remove_child(btn)
			btn.queue_free()

		index += 1

func _on_close_requested():
	print("[SaveSelect] _on_close_requested")
	hide()
	emit_signal("resolved", { "selected": false })

func _on_go_back_requested():
	print("[SaveSelect] _on_go_back_requested")
	hide()
	emit_signal("resolved", { "selected": false })

func _on_save_as_button_pressed():
	print("[SaveSelect] _on_save_as_button_pressed")
	var resolution:Dictionary = await Popups.save_as()
	if resolution["entered"]:
		_on_saved_game_pressed(resolution["name"])

func _on_saved_game_pressed(name:String):
	print("[SaveSelect] _on_saved_game_pressed('%s')" % name)
	var confirmed:bool = true
	if select_mode == "save" && Saves.has_game_name(name):
		confirmed = await Popups.confirm_action(
			"Overwrite save?",
			"Really replace saved game '%s' with the current game's progress?" % name
		)
	
	if confirmed:
		hide()
		emit_signal("resolved", { "selected": true, "name": name })
