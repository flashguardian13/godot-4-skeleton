extends Window

func _ready():
	var audio_vbox:VBoxContainer = $VBoxContainer/AudioPanel/MarginContainer/VBoxContainer
	var audio_labels:Array = [
		audio_vbox.get_node("MainVolumeSlider/Label"),
		audio_vbox.get_node("SoundVolumeSlider/Label"),
		audio_vbox.get_node("MusicVolumeSlider/Label")
	]
	var audio_label_widths:Array = audio_labels.map(func(label): return label.size.x)
	for label in audio_labels:
		label.custom_minimum_size.x = audio_label_widths.max()

func _input(event):
	if event is InputEventKey:
		var key_event:InputEventKey = event
		if key_event.pressed:
			if key_event.keycode == KEY_ESCAPE:
				hide()

func _on_close_requested():
	hide()

func _on_go_back_requested():
	hide()

func _on_about_to_popup():
	var audio_vbox:VBoxContainer = $VBoxContainer/AudioPanel/MarginContainer/VBoxContainer
	var volume_slider_names:Array = ["MainVolumeSlider", "SoundVolumeSlider", "MusicVolumeSlider"]
	for slider_name in volume_slider_names:
		var slider = audio_vbox.get_node(slider_name)
		slider.update_from_bus()
