extends HBoxContainer

@export var bus_name:String

func _bus_index() -> int:
	return AudioServer.get_bus_index(bus_name)

func update_from_bus() -> void:
	$HSlider.value = db_to_linear(AudioServer.get_bus_volume_db(_bus_index()))

func _on_h_slider_value_changed(value):
	AudioServer.set_bus_volume_db(_bus_index(), linear_to_db(value))
