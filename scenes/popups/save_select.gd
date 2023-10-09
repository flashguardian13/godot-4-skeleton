extends Window

# Presents the user with a list of options for saving or loading their games.
# The user's selection is not handled here; instead, the caller should listen
# for the "resolved" signal and expect a Dictionary with the following keys:
# selected: true if the user selected a save, false if they canceled
# name: the name of the selected save

# Game save buttons will be instantiated as needed
var saved_game_button:PackedScene = preload("res://scenes/components/saved_game.tscn")

signal resolved(result)

# This popup is used to select games when loading and when saving. This value
# tells the popup which function will be performed by the caller so it can
# present saved game information and options appropriately. Valid values: "load"
# or "save".
var _select_mode:String = "load"
func set_select_mode(mode:String) -> void:
	_select_mode = mode
	match _select_mode:
		"load":
			$ScrollContainer/VBoxContainer/SaveAsButton.visible = false
		"save":
			$ScrollContainer/VBoxContainer/SaveAsButton.visible = true
		_:
			assert(false, "[SaveSelect] Unexpected selection mode: '' %s" % mode)

func _on_about_to_popup():
	_update_saved_game_buttons()

# Refreshes the list of saved games to reflect what is currently stored on disk.
func _update_saved_game_buttons() -> void:
	# Discover any existing saved game buttons
	var children:Array = $ScrollContainer/VBoxContainer.get_children()
	# Leave the "Save As" button alone
	children.erase($ScrollContainer/VBoxContainer/SaveAsButton)
	# Get the list of saved game names from the Saves singleton
	var save_names:Array = Saves.get_save_names()
	# Iterate over the lists of buttons and saved game names in tandem
	var info:Dictionary
	var btn:Button
	var index:int = 0
	while index < children.size() || index < save_names.size():
		# If we have a save at this index, get summarized information about it
		if index < save_names.size():
			info = Saves.get_save_info(save_names[index])
		# If we have a button at this index, disassociate it from any prior save
		if index < children.size():
			btn = children[index]
			btn.pressed.disconnect(_on_saved_game_pressed)
		# Otherwise, instantiate a new button
		else:
			btn = saved_game_button.instantiate()
			$ScrollContainer/VBoxContainer.add_child(btn)
		# If we have a save at this index, pair our button with it
		if index < save_names.size():
			btn.update_display(info)
			print("[SaveSelect] connecting save game button for '%s'" % info["name"])
			btn.pressed.connect(_on_saved_game_pressed.bind(info["name"]))
		# Otherwise, dispose of this button
		else:
			$ScrollContainer/VBoxContainer.remove_child(btn)
			btn.queue_free()
		# Next!
		index += 1
	# The saved game selection dialog does not auto-size to fit its contents.
	# I'm not sure why. The ScrollContainer is set to fill all availaable space
	# given to it by us (its parent Window), but we never seem to offer more
	# than our configured minimum. (Because the ScrollContainer never asks for
	# more?) Here, we adjust our minimum height to maintain parity with the
	# combined height of all of our buttons, within our desired range. It would
	# be preferable to have this done automatically if I ever figure out how.
	var content_height:float = $ScrollContainer/VBoxContainer.get_minimum_size().y
	min_size.y = clampf(content_height, 100.0, 600.0)

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
	# If the user wants us to save over an existing game, get comfirmation.
	if _select_mode == "save" && Saves.has_game_name(name):
		confirmed = await Popups.confirm_action(
			"Overwrite save?",
			"Really replace saved game '%s' with the current game's progress?" % name
		)

	if confirmed:
		# As a general note, it is important to hide FIRST and then send the
		# signal because emitting the signal might show this dialog (as in the
		# case where the user wants to load a game but then opts to save first).
		# If we were to reverse the order of operations, the dialog would be
		# shown and then hidden, breaking the expected flow.
		hide()
		emit_signal("resolved", { "selected": true, "name": name })
