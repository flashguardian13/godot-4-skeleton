extends Node

var button_entered_sounds:Array = [
	ResourceLoader.load("res://sounds/button_hover/408209__idalize__chalk-scuff_01.wav"),
	ResourceLoader.load("res://sounds/button_hover/408209__idalize__chalk-scuff_02.wav"),
	ResourceLoader.load("res://sounds/button_hover/408209__idalize__chalk-scuff_03.wav"),
	ResourceLoader.load("res://sounds/button_hover/408209__idalize__chalk-scuff_04.wav"),
	ResourceLoader.load("res://sounds/button_hover/408209__idalize__chalk-scuff_05.wav"),
	ResourceLoader.load("res://sounds/button_hover/408209__idalize__chalk-scuff_08.wav")
]

var button_pressed_sounds:Array = [
	ResourceLoader.load("res://sounds/button_click/408209__idalize__chalk-hard-tap_07.wav"),
	ResourceLoader.load("res://sounds/button_click/408209__idalize__chalk-hard-tap_08.wav"),
	ResourceLoader.load("res://sounds/button_click/408209__idalize__chalk-hard-tap_09.wav")
]

var player:AudioStreamPlayer = null

func _ready():
	_connect_buttons_recursively(get_tree().root)
	get_tree().node_added.connect(_on_SceneTree_node_added)

func _connect_buttons_recursively(node:Node) -> void:
	for child in node.get_children():
		if child is Button:
			_add_sounds_to_button(child)
		_connect_buttons_recursively(child)

func _on_SceneTree_node_added(node):
	if node is Button:
		_add_sounds_to_button(node)

func _add_sounds_to_button(button:Button) -> void:
	button.mouse_entered.connect(_on_Button_mouse_entered)
	button.pressed.connect(_on_Button_pressed)

func _get_player() -> AudioStreamPlayer:
	if player == null:
		player = AudioStreamPlayer.new()
		player.bus = "Sound"
		add_child(player)
	return player

func _on_Button_mouse_entered() -> void:
	var player = _get_player()
	if player.playing:
		return
	var stream:AudioStream = button_entered_sounds.pick_random() as AudioStream
	player.stream = stream
	player.play()

func _on_Button_pressed() -> void:
	var player = _get_player()
	if player.playing:
		return
	var stream:AudioStream = button_pressed_sounds.pick_random() as AudioStream
	player.stream = stream
	player.play()
