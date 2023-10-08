extends Node

const CONFIG_PATH:String = "user://config.json"
var _values
var valid_keys:Array = [
	"volume.Master",
	"volume.Music",
	"volume.Sound"
]

func _ready():
	if FileAccess.file_exists(CONFIG_PATH):
		var file:FileAccess = FileAccess.open(CONFIG_PATH, FileAccess.READ)
		_values = JSON.parse_string(file.get_as_text())
	else:
		_values = {}

	for bus_name in ["Master", "Music", "Sound"]:
		var linear_volume:float = get_value("volume.%s" % bus_name, 1.0)
		var bus_index:int = AudioServer.get_bus_index(bus_name)
		AudioServer.set_bus_volume_db(bus_index, linear_to_db(linear_volume))

func save() -> void:
	var file:FileAccess = FileAccess.open(CONFIG_PATH, FileAccess.WRITE)
	assert(file != null, "[Config] error saving to config file: %s" % FileAccess.get_open_error())
	file.store_string(JSON.stringify(_values))

func _dig(keys:Array, node):
	if keys.size() <= 0:
		return node

	if !(node is Dictionary):
		assert(false, "[Config] error digging: node is not a Dictionary: %s" % node)

	if !node.has(keys[0]):
		if keys.size() == 1:
			return null
		else:
			node[keys[0]] = {}

	return _dig(keys.slice(1), node[keys[0]])

func _validate_key(key:String):
	if !valid_keys.has(key):
		assert(false, "[Config] bad key: %s" % key)

func get_value(key:String, default = null):
	print("[Config] Getting value '%s' ..." % key)
	_validate_key(key)
	var tokens:PackedStringArray = key.split(".")
	var value = _dig(tokens, _values)
	return default if value == null else value

func set_value(key:String, value) -> void:
	print("[Config] Setting value of '%s' to '%s' ..." % [key, value])
	_validate_key(key)
	var tokens:PackedStringArray = key.split(".")
	var parent = _dig(tokens.slice(0, -1), _values)
	parent[tokens[-1]] = value
