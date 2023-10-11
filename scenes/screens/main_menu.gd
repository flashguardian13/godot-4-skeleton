extends MarginContainer

const BG_SCROLL_SPEED:Vector2 = Vector2(10, 10)

func _ready():
	_update_buttons()

func _process(delta):
	$ParallaxBackground.scroll_offset += BG_SCROLL_SPEED * delta

func _update_buttons() -> void:
	$CenterContainer/VBoxContainer/ResumeButton.visible = GameState.is_active
	$CenterContainer/VBoxContainer/SaveButton.visible = GameState.is_active
	$CenterContainer/VBoxContainer/LoadButton.visible = Saves.get_save_names().size() > 0

func _on_quit_button_pressed():
	print("[MainMenu] _on_quit_button_pressed")
	if GameState.is_active:
		var verdict:String = await Popups.save_first()
		match verdict:
			"confirmed":
				var should_continue:bool = await _select_game_and_save()
				if !should_continue:
					return
			"denied":
				pass
			"canceled":
				return
			_:
				assert(false, "Unexpected verdict from save_first: '%s'" % verdict)

	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)

func _on_new_button_pressed():
	print("[MainMenu] _on_new_button_pressed")
	if GameState.is_active:
		var verdict:String = await Popups.save_first()
		match verdict:
			"confirmed":
				var should_continue:bool = await _select_game_and_save()
				if !should_continue:
					return
			"denied":
				pass
			"canceled":
				return
			_:
				assert(false, "Unexpected verdict from save_first: '%s'" % verdict)

	GameState.reset_board()
	Transitions.start_transition("res://scenes/transitions/fade_to_black.tscn", "res://scenes/screens/tic_tac_toe.tscn")

func _on_resume_button_pressed():
	Transitions.start_transition("res://scenes/transitions/fade_to_black.tscn", "res://scenes/screens/tic_tac_toe.tscn")

func _on_load_button_pressed():
	if GameState.is_active:
		var verdict:String = await Popups.save_first()
		match verdict:
			"confirmed":
				var should_continue:bool = await _select_game_and_save()
				if !should_continue:
					return
			"denied":
				pass
			"canceled":
				return
			_:
				assert(false, "Unexpected verdict from save_first: '%s'" % verdict)

	var should_continue:bool = await _select_game_and_load()
	if !should_continue:
		return

	Transitions.start_transition("res://scenes/transitions/fade_to_black.tscn", "res://scenes/screens/tic_tac_toe.tscn")

func _on_save_button_pressed():
	await _select_game_and_save()

func _select_game_and_save() -> bool:
	var result:Dictionary = await Popups.select_save("save")
	if result["selected"]:
		Saves.save_by_name(result["name"])
	return result["selected"]

func _select_game_and_load() -> bool:
	var result:Dictionary = await Popups.select_save("load")
	if result["selected"]:
		Saves.load_by_name(result["name"])
	return result["selected"]
