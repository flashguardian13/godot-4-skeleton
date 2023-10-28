extends MarginContainer

# The game's main menu, from which the player can start a new game, load, save,
# or quit.

# The path to our background music
# Sound from Zapsplat.com
const BG_MUSIC_PATH:String = "res://assets/music/music_zapsplat_game_music_childrens_soft_warm_cuddly_calm_015.mp3"

# Controls the background's scroll speed (world units per second)
const BG_SCROLL_SPEED:Vector2 = Vector2(10, 10)

func _ready():
	_update_buttons()
	Music.get_player().cross_fade_to(BG_MUSIC_PATH)

func _process(delta):
	# Scroll the background
	$ParallaxBackground.scroll_offset += BG_SCROLL_SPEED * delta

# Updates the visibility of our buttons based on game state and available saves.
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
	# Send a request to close the app. This will trigger pre-close behaviors.
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
	# Restart the game
	GameState.reset_board()
	Transitions.start_transition(Transitions.TRANSITION_FADE_TO_BLACK, Transitions.SCREEN_TIC_TAC_TOE)

func _on_resume_button_pressed():
	Transitions.start_transition(Transitions.TRANSITION_FADE_TO_BLACK, Transitions.SCREEN_TIC_TAC_TOE)

func _on_load_button_pressed():
	print("[MainMenu] _on_load_button_pressed")
	if GameState.is_active:
		var verdict:String = await Popups.save_first()
		print("[MainMenu] save first verdict: %s" % verdict)
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
	# Prompt the user to select a game to load
	var should_continue:bool = await _select_game_and_load()
	print("[MainMenu] should_continue loading: %s" % should_continue)
	if !should_continue:
		return
	# Load the selected game
	Transitions.start_transition(Transitions.TRANSITION_FADE_TO_BLACK, Transitions.SCREEN_TIC_TAC_TOE)

func _on_save_button_pressed():
	await _select_game_and_save()

# Shows the save select popup, waits for it to resolve, then saves the current
# game if a save name was selected.
func _select_game_and_save() -> bool:
	print("[MainMenu] _select_game_and_save")
	var result:Dictionary = await Popups.select_save("save")
	print("[MainMenu] select_save result for save: %s" % result)
	if result["selected"]:
		Saves.save_by_name(result["name"])
	return result["selected"]

# Shows the save select popup, waits for it to resolve, then loads the saved
# game if one was selected.
func _select_game_and_load() -> bool:
	print("[MainMenu] _select_game_and_load")
	var result:Dictionary = await Popups.select_save("load")
	print("[MainMenu] select_save result for load: %s" % result)
	if result["selected"]:
		Saves.load_by_name(result["name"])
	return result["selected"]

func _on_settings_button_pressed():
	Popups.settings()
