extends HBoxContainer

# General purpose volume slider, intended for use by the Settings popup.

# The name of the audio bus whose volume this slider shall manage. Exported so
# that it can be configured (overridden) via the Godot UI.
@export var bus_name:String

# Convenience method for getting our bus's index from its name.
func _bus_index() -> int:
	return AudioServer.get_bus_index(bus_name)

# Sets this slider's position based on the current volume of our bus. Used by
# the Settings popup to sync bus volume with slider position just before the
# popup appears to the user.
func update_from_bus() -> void:
	$HSlider.value = db_to_linear(AudioServer.get_bus_volume_db(_bus_index()))

func _on_h_slider_value_changed(value):
  # Set our audio bus's volume based on the (new) slider position.
	AudioServer.set_bus_volume_db(_bus_index(), linear_to_db(value))
	# Persist this volume setting between play sessions.
	Config.set_value("volume.%s" % bus_name, value)
