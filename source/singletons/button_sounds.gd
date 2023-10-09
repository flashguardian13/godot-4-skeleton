extends Node

# This auto-loaded node has one job: attach sound effects to all buttons in the
# UI.
#
# We want our buttons to play sounds when the mouse enters them and when they
# are clicked. Unfortunately, this is not something that can be achieved using
# Godot's UI styling. As a workaround, this singleton is loaded, it searches the
# scene tree for buttons and connects its sound-playing methods to the
# "mouse_entered" and "pressed" signals emitted by those buttons. It then sits
# in the background listening, waiting for new buttons to enter the scene tree,
# and likewise adds audio to those buttons.
#
# Thank you, Jummit, for this solution!
# https://gamedev.stackexchange.com/a/184363/174636

# A group of sounds to be played randomly on button entry.
var button_entered_sounds:Array = [
	ResourceLoader.load("res://sounds/button_hover/408209__idalize__chalk-scuff_01.wav"),
	ResourceLoader.load("res://sounds/button_hover/408209__idalize__chalk-scuff_02.wav"),
	ResourceLoader.load("res://sounds/button_hover/408209__idalize__chalk-scuff_03.wav"),
	ResourceLoader.load("res://sounds/button_hover/408209__idalize__chalk-scuff_04.wav"),
	ResourceLoader.load("res://sounds/button_hover/408209__idalize__chalk-scuff_05.wav"),
	ResourceLoader.load("res://sounds/button_hover/408209__idalize__chalk-scuff_08.wav")
]
# A group of sounds to be played on button press.
var button_pressed_sounds:Array = [
	ResourceLoader.load("res://sounds/button_click/408209__idalize__chalk-hard-tap_07.wav"),
	ResourceLoader.load("res://sounds/button_click/408209__idalize__chalk-hard-tap_08.wav"),
	ResourceLoader.load("res://sounds/button_click/408209__idalize__chalk-hard-tap_09.wav")
]
# Thank you, freesound.org!

# This variable will hold a reference to the non-positional player through which
# we will play our sounds.
#
# I suppose we could use positional players for better immersive effect, but
# that would take more work because we'd be attaching an AudioStreamPlayer2D to
# each discovered button, then using it to play sound. Do-able, so ... TODO.
var player:AudioStreamPlayer = null

func _ready():
	# Connect all existing buttons
	_connect_buttons_recursively(get_tree().root)
	# Listen for new buttons
	get_tree().node_added.connect(_on_SceneTree_node_added)

# Here we crawl the entire scene tree looking for buttons. As we discover them,
# we refer them to our audio decoration function.
func _connect_buttons_recursively(node:Node) -> void:
	for child in node.get_children():
		if child is Button:
			_add_sounds_to_button(child)
		# Does this child have children? Inspect those.
		_connect_buttons_recursively(child)

func _on_SceneTree_node_added(node):
	# Did we just add a button? Refer it to our audio decoration function.
	if node is Button:
		_add_sounds_to_button(node)

# Connects our sound-playing methods to the button's signals.
func _add_sounds_to_button(button:Button) -> void:
	button.mouse_entered.connect(_on_Button_mouse_entered)
	button.pressed.connect(_on_Button_pressed)

# Returns our audio player, instantiating it if not done already.
func _get_player() -> AudioStreamPlayer:
	if player == null:
		player = AudioStreamPlayer.new()
		player.bus = "Sound"
		add_child(player)
	return player

func _on_Button_mouse_entered() -> void:
	var player = _get_player()
	# Skip playing if already playing
	if player.playing:
		return
	# Play a random sound for entering a button.
	var stream:AudioStream = button_entered_sounds.pick_random() as AudioStream
	player.stream = stream
	player.play()

func _on_Button_pressed() -> void:
	var player = _get_player()
	# Skip playing if already playing
	if player.playing:
		return
	# Play a random sound for pressing a button.
	var stream:AudioStream = button_pressed_sounds.pick_random() as AudioStream
	player.stream = stream
	player.play()
